LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY codec_init IS
	GENERIC (
		CONSTANT fdiv_max : NATURAL := 499;
		CONSTANT bcnt_max : NATURAL := 28;
		CONSTANT wcnt_max : NATURAL := 10
	);
	PORT 
	(
		CLOCK_50	: IN  STD_LOGIC; -- master clock
		RES_N		: IN  STD_LOGIC; -- reset, active 0
		SCLK		: OUT STD_LOGIC; -- serial clock
		SDIN		: OUT STD_LOGIC  -- serial data
	);
END ENTITY;

ARCHITECTURE rtl OF codec_init IS
	CONSTANT sdin_load : STD_LOGIC_VECTOR (11*24-1 DOWNTO 0) := 
		b"0011010_0_0001111_000000000"&
		b"0011010_0_0000000_000010111"&
		b"0011010_0_0000001_000010111"&
		b"0011010_0_0000010_001111001"&
		b"0011010_0_0000011_001111001"&
		b"0011010_0_0000100_011010010"&
		b"0011010_0_0000101_000000001"&
		b"0011010_0_0000110_001100010"&
		b"0011010_0_0000111_001000011"&
		b"0011010_0_0001000_000100000"&
		b"0011010_0_0001001_000000001";
	-- 11 words, the first is reset (R15), the others are registers R0-9.
	-- each word is 24 bit constructed as
	-- chip address, r/w bit, reg address, reg data
	-- these words do not include start, stop and ack bits

	-- Packet format:            (bit number) 
	-- 1 start bit               28
	-- 7 bits chip address       27-21
	-- 1 r/w bit                 20
	--** ack                     19
	-- 8 high bits of reg. data  18-11
	--** ack                     10
	-- 8 low bits of reg. data   9-2
	--** ack                     1
	-- 1 stop bit                0

	-- reg. data = 7 bit address + 9 bit config data, 16 bits total,
	-- split as 8+8 bits in the packet, MSB go first.

	-- Shift register
	SIGNAL sr    : STD_LOGIC_VECTOR (11*24-1 DOWNTO 0);

	-- Internal signal to be copied into SDIN at the end
	SIGNAL sdout : STD_LOGIC;

	-- Frequency divider counter, runs at 50MHz
	SIGNAL f_div : INTEGER;

	-- Bit counter, runs at 100kHz,
	-- nb. bits 28, 19, 10, 1 and 0 are special
	SIGNAL bcnt  : INTEGER;

	-- Word counter, runs at about 5kHz
	SIGNAL wcnt  : INTEGER;

BEGIN

	PROCESS (CLOCK_50)
	BEGIN
		IF (rising_edge(CLOCK_50)) THEN

			-------------------------------------
			-- Counter Functionality
			-------------------------------------

			-- Reset actions
			IF (RES_N = '0') THEN
				-- reset the counters
				f_div <= fdiv_max;
				bcnt  <= bcnt_max;
				wcnt  <= wcnt_max;
				-- load the shift register
				sr    <= sdin_load;
				-- reset the outputs to an appropriate state
				SCLK  <= '0';
				sdout <= '1';

			-- Just do nothing at the end, wait for the next reset
			ELSIF ((wcnt = 0) AND (bcnt = 0) AND (f_div = 0)) THEN

			-- Update reference counters at the end of each bit
			ELSIF (f_div = 0) THEN
				f_div <= fdiv_max; -- always reset frquency divider
				IF (bcnt = 0) THEN
					bcnt <= bcnt_max; -- reset bit counter at end of word
					wcnt <= wcnt - 1;
				ELSE
					bcnt <= bcnt - 1;
				END IF;

			-- If not the end of a bit, keep decrementing frequency divider
			ELSE
				f_div <= f_div - 1;
			END IF;

			------------------------------------------------
			-- Output generation functionality
			------------------------------------------------

			-- Generate SCLK, it is 90 degrees out of phase from SDIN bits
			IF (f_div = (fdiv_max - (fdiv_max / 4)) ) THEN
				SCLK <= '1';
			ELSIF (f_div = (fdiv_max / 4)) THEN
				SCLK <= '0';
			END IF;
			
			-- Generate serial data output - 4 possible cases to deal with
			-- Send 'start transition' on the first bit
			IF ((bcnt = 28) AND (f_div = (fdiv_max / 2))) THEN
				sdout  <= '0';
			-- Send 'stop transition' on the last bit. Requires two output changes
			-- set low at start of bit amd transition high half way thru)
			ELSIF ((bcnt = 1) AND (f_div = 0)) THEN
				sdout <= '0';
			ELSIF ((bcnt = 0) AND (f_div = (fdiv_max / 2))) THEN
				sdout <= '1';
			-- Set output to High Impedance just before the actual bit,
			-- to receive one of the three ACK bits on the 19th, 10th and 1st bit
			ELSIF (((bcnt=20) OR (bcnt=11) OR (bcnt=2)) AND (f_div = 0)) THEN
				sdout <= 'Z';
			-- Send the actual data on the 'Non-Special' bits
			ELSIF ((f_div = 0) AND (bcnt /= 0) AND (bcnt /= 1)) THEN
				sr <= sr((11*24-2) DOWNTO 0) & '0' ; -- Shift the Shift Register
				sdout <= sr(11*24-1); -- Output the first bit on the shift register
			END IF;

		END IF;
	END PROCESS;

	SDIN <= sdout; 			
					
END rtl;