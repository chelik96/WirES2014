--------------------------------------------------------------------------------
-- UART - Universal Asynchronous Receiver/Transceiver
--        For EEE8097 Masters Project
--
-- Converts RS-232 serial input into parallel 8-bit (Byte) output
-- and parallel 8-bit input into serial RS-232 output
--
-- Copyright (C) 2014 Michael Walker
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;

ENTITY UART IS
	GENERIC(
		F_CLK : INTEGER := 50000000;  -- Master clock frequency: default = 50MHz
		BAUD  : INTEGER := 115200;    -- Baud for RS-232: default = 115,200
		BITS  : INTEGER := 8          -- Number of Data Bits
	);
	PORT
	(
		CLK : IN  STD_LOGIC;                     -- Master Clock (50MHz)
		RST : IN  STD_LOGIC;                     -- Reset (Active Low)
		RXD : IN  STD_LOGIC; -- UART Serial In
		TXD : OUT STD_LOGIC; -- UART Serial Out
		DRX : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- SIPO Register for Receiver
		DTX : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); -- PISO Register for Transmitter
		STR : OUT STD_LOGIC; -- Strobe out when a byte completely received
		STT : IN  STD_LOGIC  -- Strobe in when a byte is ready to be transmitted
	);
END ENTITY;

ARCHITECTURE rtl OF UART IS

	-- Defaults 50M/115200 = 434 clock cycles per bit
	CONSTANT FRQ_BIT  : INTEGER := F_CLK / BAUD;
	-- Need width to count down from 1.5 times the cycles per bit constant
	CONSTANT MAX_FRQ  : INTEGER := FRQ_BIT + (FRQ_BIT / 2);
	CONSTANT FRQ_WIDTH: INTEGER := INTEGER(ceil(log2(REAL(MAX_FRQ))));
	-- Need width to count all data bits and include a 'no more bits' state too
	CONSTANT BIT_WIDTH: INTEGER := INTEGER(ceil(log2(REAL(BITS + 1))));
	-- Counters for timing length of one bit based on cycles of the master clock
	SIGNAL FRQ_CNT_RX : UNSIGNED(FRQ_WIDTH - 1 DOWNTO 0);
	SIGNAL FRQ_CNT_TX : UNSIGNED(FRQ_WIDTH - 1 DOWNTO 0);
	-- Counters for counting the data bits in one RS-232 'packet'
	SIGNAL BIT_CNT_RX : UNSIGNED(BIT_WIDTH - 1  DOWNTO 0);
	SIGNAL BIT_CNT_TX : UNSIGNED(BIT_WIDTH - 1  DOWNTO 0);
	-- Readable copy of unreadable STR output
	SIGNAL STR_INT    : STD_LOGIC;

BEGIN

	PROCESS (CLK, RST)
	BEGIN
		-- Reset Condition
		IF (RST ='0') THEN
			FRQ_CNT_RX <= (OTHERS=>'0');
			FRQ_CNT_TX <= (OTHERS=>'0');
			BIT_CNT_RX <= (OTHERS=>'0');
			BIT_CNT_TX <= (OTHERS=>'0');
			STR_INT    <= '0';
		-- Normal Operating Conditions
		ELSIF (RISING_EDGE(CLK)) THEN

			-- RECEIVER SECTION
			-------------------
			-- If both counters 'finished' counting down then just go idle and
			-- Wait for a start bit, this is when signal on RXD goes low
			IF ((BIT_CNT_RX = 0) AND (FRQ_CNT_RX = 0)) THEN
				-- The Start bit just arrived - get ready to read data bits
				IF (RXD = '0') THEN
					-- Wait for start bit to finish, plus wait another half bit
					-- to allow data have settled when read
					FRQ_CNT_RX <= TO_UNSIGNED(MAX_FRQ, FRQ_WIDTH);
					BIT_CNT_RX <= TO_UNSIGNED(BITS, BIT_WIDTH);
				END IF;
			-- If end of frequency count, but not bit count, then it is time
			-- to receive a bit and store it in the register
			ELSIF ((BIT_CNT_RX < BITS) AND (BIT_CNT_RX > 0) AND
				   (FRQ_CNT_RX = 0)) THEN
				-- Store the received bit value
				-- Nb. Serial data is Little-Endian; LSB comes first
				DRX(BITS - TO_INTEGER(BIT_CNT_RX)) <= RXD;
				-- Reset the clocks per bit counter; wait for middle of next bit
				FRQ_CNT_RX <= TO_UNSIGNED(FRQ_BIT, FRQ_WIDTH);
				-- If this is the last bit to be received then trigger the
				-- strobe to indicate parallel data now ready to be read.
				IF BIT_CNT_RX = 1 THEN
					STR_INT<='1';
				END IF;
				-- Decrement the bit counter; because this bit now processed
				BIT_CNT_RX <= BIT_CNT_RX - 1;
			-- If not at the end of the frequency count, then nothing to do
			-- but continue counting down until it is at the end...
			ELSE
				FRQ_CNT_RX <= FRQ_CNT_RX - 1;
			END IF;
			
			-- Always reset the strobe on the next clock cycle
			IF (STR_INT='1') THEN
				STR_INT <= '0';
			END IF;
			
			-- TRANSMITTER SECTION
			----------------------
			-- If a strobe to transmit is received then start up the
			-- transmission process
			IF (STT = '1') THEN
				-- First bit to send is the Start bit, which is always '0'
				TXD        <= '0';
				-- Start up the Counters for transmitting
				FRQ_CNT_TX <= TO_UNSIGNED(FRQ_BIT - 1, FRQ_WIDTH);
				BIT_CNT_TX <= TO_UNSIGNED(BITS, BIT_WIDTH);
			-- If Data bits to send, send them a end of frequency count
			ELSIF ((FRQ_CNT_TX = 0) AND (BIT_CNT_TX > 0)) THEN
				-- Send the current Data bit (nb. LSB First)
				TXD        <= DTX(BITS - TO_INTEGER(BIT_CNT_TX));
				-- Update counters
				BIT_CNT_TX <= BIT_CNT_TX - 1;
				FRQ_CNT_TX <= TO_UNSIGNED(FRQ_BIT -1, FRQ_WIDTH);
			-- If sent all the data bits, send stop bit (1) and go idle
			ELSIF FRQ_CNT_TX=0 AND BIT_CNT_TX=0 THEN
				TXD <= '1';
			-- not the end of the frequency count yet, so keep counting
			-- down until it is at an end
			ELSE
				FRQ_CNT_TX <= FRQ_CNT_TX - 1;
			END IF;

		END IF;
	END PROCESS;

	-- Keep track of the strobe output which cannot be read in the process
	-- by maintaining an internal signal copy that can be read.
	STR <= STR_INT;

END rtl;
