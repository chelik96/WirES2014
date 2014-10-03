--------------------------------------------------------------------------------
-- SRAM - Wrapper around the SRAM chip on-board the DE1
--        For EEE8097 Masters Project
--
-- Converts received 4 character ASCII hexadecimal into 16-bit Address
-- and sets the 18-bit address bus to the same (with 2 MSB set to '00').
-- then it converts 16-bit data bus values to transmit as ASCII hexadecimal.
--
-- Copyright (C) 2014 Michael Walker
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY SRAM IS
	PORT(
		CLK : IN  STD_LOGIC;                     -- MAIN Clock
		RST : IN  STD_LOGIC;                     -- Reset (Active Low)

		AIN : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Hexadecimal Nibble In
		AOT : OUT STD_LOGIC_VECTOR(17 DOWNTO 0); -- Address Bus to SRAM Memory

		DIN : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); -- Data Bus to SRAM Memory
		DOT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Hexadecimal Nibble Out

		STR : IN  STD_LOGIC; -- Strobe from UART when it receives a byte
		STT : OUT STD_LOGIC; -- Strobe to UART when it should transmit a byte

		WEN : OUT STD_LOGIC;                     -- Write Enable  (Active Low)
		OEN : OUT STD_LOGIC                      -- Output Enable (Active Low)
	);
END ENTITY;

ARCHITECTURE rtl OF SRAM IS

	-- There are 4 HEX characters per 16-bit address to receive or data to send
	-- 4 'modes': upper '11' for highest nibble or lower '00' for lowest nibble
	SIGNAL TMODE: UNSIGNED( 1 DOWNTO 0); -- keep track of nibble to transmit
	SIGNAL TPREV: UNSIGNED( 1 DOWNTO 0); -- previous TMODE, watched for change
	SIGNAL RMODE: UNSIGNED( 1 DOWNTO 0); -- keep track of nibble to be received
	-- Counter to wait for current transmission to finish before sending another
	SIGNAL TWAIT: UNSIGNED(13 DOWNTO 0); -- Wait for 10 bits * 443 clocks = 4430

BEGIN

	WEN <= '1'; -- Prevent ability to write data to SRAM (Inactive high)
	OEN <= '0'; -- Ensure ability to output data from SRAM (Active low)

	PROCESS (CLK, RST)
		-- temporary stores for conversion of ASCII to binary nibbles
		VARIABLE RNIB: UNSIGNED(3 DOWNTO 0);
		VARIABLE TNIB: UNSIGNED(3 DOWNTO 0);
		VARIABLE VALIDHEX: BOOLEAN;
	BEGIN
		VALIDHEX := FALSE;
		-- Reset Condition
		IF (RST = '0') THEN
			RMODE <= "11"; -- Start receive  at upper nibble first
			TMODE <= "11"; -- Start transmit at upper nibble first
			AOT(17 DOWNTO 16) <= "00"; -- Leave the 2 MSBs unchanged
			AOT(15 DOWNTO 0)  <= (OTHERS => '0'); -- Reset memory address
		-- Normal Operating Conditions
		ELSIF RISING_EDGE(CLK) THEN
			-- Prevent inferred latches for unchanged 2 MSB in address
			AOT(17 DOWNTO 16) <= "00"; -- Leave 2 MSB unchanged

			-- RECEIVER SECTION
			-------------------
			-- Check if strobe received , if so, set received address
			IF (STR = '1') THEN
			
				-- Calculate 4-bit binary value of hexadecimal character,
				-- ensuring ASCII character is a valid hex - (0-9 or a-f).
				-- First - Numbers (in ASCII upper 4 bits will be '0011')
				-- note Lower nibble of the ASCII will map correctly for number
				IF ((AIN(7 DOWNTO 4) = "0011") AND
					(AIN(3 DOWNTO 0) < "1010")) THEN
					-- Set nibble value ready to place on address bus
					RNIB   := UNSIGNED(AIN(3 DOWNTO 0));
					VALIDHEX := TRUE;
				-- Second - Letters (either lower or upper case: a-f OR A-F)
				-- (in ASCII upper four bits will be 0110 for lower case
				--  or 0100 for upper case. lower bit will be 0001 for 'a/A'
				--  up to 0110 for 'f/F'. this means they are offset 9 
				--  lower than their correct binary/hexadecimal value..
				--  eg. HEX A = BIN 1010, but lower nibble of ASCII A is '0001'
				--  to convert ADD '9'... this means 0001 + 1001 = 1010 = HEX A)
				ELSIF ((AIN(7 DOWNTO 4) = "0110") OR
					   (AIN(7 DOWNTO 4) = "0100")) AND
					  (AIN(3 DOWNTO 0) < "0111") THEN
					-- Set nibble value ready to place on address bus
					RNIB     := UNSIGNED(AIN(3 DOWNTO 0)) + TO_UNSIGNED(9,4);
					VALIDHEX := TRUE;
				END IF;

				IF (VALIDHEX) THEN
					IF (RMODE = "11") THEN
						AOT(15 DOWNTO 12) <= STD_LOGIC_VECTOR(RNIB);
						RMODE <= "01";
					ELSIF RMODE = "10" THEN
						AOT(11 DOWNTO  8) <= STD_LOGIC_VECTOR(RNIB);
						RMODE <= "01";
					ELSIF RMODE = "01" THEN
						AOT( 7 DOWNTO  4) <= STD_LOGIC_VECTOR(RNIB);
						RMODE <= "00";
					ELSIF RMODE = "00" THEN
						AOT( 3 DOWNTO  0) <= STD_LOGIC_VECTOR(RNIB);
						RMODE <= "11";
						-- Got full address word, so transmit data after small
						-- delay to allow SRAM output to settle
						TWAIT <= TWAIT + TO_UNSIGNED(3,14);
						-- Just ensure upper bit sent first...
						TMODE <= "11";
					-- now check fOR letters a-f OR A-F
					END IF;
				END IF;
			END IF;

			-- TRANSMITTER SECTION
			----------------------
			-- If something ready to send and UART ready then send it
			-- use penultimate count (1) to set up transmission, so that the
			-- final count (0) can be used to return system to an idle state.

			-- First - if we are waiting to be ready, then just keep waiting
			IF (TWAIT >  TO_UNSIGNED(1,14)) THEN
				TWAIT <= TWAIT - TO_UNSIGNED(1,14);
			-- Penultimate Count - setup for transmission of memory contents
			ELSIF (TWAIT = TO_UNSIGNED(1,14)) THEN
				-- Set strobe for transmission of a byte by UART high
				STT   <= '1';
				-- ensure countdown stops next cycle - hard set count to zero
				TWAIT <= TO_UNSIGNED(0,14);

				-- Extract nibble to send as hex from SRAM data bus
				CASE TMODE IS
					WHEN "11" => TNIB := UNSIGNED(DIN(15 DOWNTO 12));
					WHEN "10" => TNIB := UNSIGNED(DIN(11 DOWNTO  8));
					WHEN "01" => TNIB := UNSIGNED(DIN( 7 DOWNTO  4));
					WHEN "00" => TNIB := UNSIGNED(DIN( 3 DOWNTO  0));
					WHEN OTHERS => TNIB := "0000";
				END CASE;

				-- Set ASCII character to be sent on this transmission --
				-- Set upper nibble to '0011' for ASCII numerals if binary < 10
				-- otherwise set it to '0100' for ASCII upper case letters (A-F)
				-- Set lower nibble directly from data bus if numeral to be used
				-- for letters, need to subtract 9 from bus data to convert.
				IF TNIB < TO_UNSIGNED(10,4) THEN
					DOT(7 DOWNTO 4) <= "0011";
					DOT(3 DOWNTO 0) <= STD_LOGIC_VECTOR(TNIB);
				ELSE
					DOT(7 DOWNTO 4) <= "0100";
					DOT(3 DOWNTO 0) <= STD_LOGIC_VECTOR(TNIB -TO_UNSIGNED(9,4));
				END IF;

				-- Update State
				-- Special case first - might need to send linefeed character
				-- override output if this is the case
				IF TMODE = "11" THEN
					TMODE <= "10";
				ELSIF TMODE = "10" THEN
					TMODE <= "01";
				ELSIF TMODE = "01" THEN
					TMODE <= "00";
				ELSIF TMODE = "00" THEN
					TMODE <= "11";
				END IF;
			-- If character just sent is NOT last of 4 then more to transmit
			ELSIF ((TMODE /= "11") AND (TPREV /= "00")) THEN
				--Reset strobe and wait for transmission of the current data
				-- before sending the next character.
				STT   <= '0';
				TWAIT <= TO_UNSIGNED(4500,14);
			ELSE
				-- Last character of data just sent, so just go idle
				-- reset strobe and await transmission of first character
				STT   <= '0';
				TMODE <= "11";
			END IF;
			-- Keep track of last process cycle Transmission mode, so that
			-- we can spot when the last character is sent
			TPREV <= TMODE;
		END IF;
	END PROCESS;
END;