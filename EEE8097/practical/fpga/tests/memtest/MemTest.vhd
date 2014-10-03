LIBRARY ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
-- std_logic_vector(to_unsigned(natural_number, nb_bits));


ENTITY MemTest IS
	GENERIC (
		-- useful constants about the 23LCV512 SRAM Chip
		CONSTANT  bits_in_byte : NATURAL := 8;
		CONSTANT bytes_in_page : NATURAL := 32;
		CONSTANT  bits_in_page : NATURAL := 256;
		CONSTANT pages_in_chip : NATURAL := 2048;
	
		CONSTANT  bits_in_chip : NATURAL := 524288;
		CONSTANT bytes_in_chip : NATURAL := 65536;
		
		CONSTANT message_bytes : NATURAL := 4;
		CONSTANT memclk_div    : NATURAL := 6
	);
  PORT 
	(
		CLOCK_50: IN  STD_LOGIC; -- master clock
		RESET_N : IN  STD_LOGIC; -- reset, active 0
		SCK		  : OUT STD_LOGIC; -- serial clock
		SI			: OUT STD_LOGIC; -- serial data ( input to   memory chip)
		SO			: IN  STD_LOGIC  -- serial data (output from memory chip)
	);
END ENTITY;

ARCHITECTURE rtl OF MemTest IS
	CONSTANT sin_startread : STD_LOGIC_VECTOR (3*bits_in_byte-1 DOWNTO 0);
	-- Bit counter, 8.3Mhz
	SIGNAL b_count : INTEGER;

	-- Word counter, 1MHz
	SIGNAL w_count : INTEGER;

	-- Message Counter - 3 bytes to write, 1 byte to read 260Khz
	SIGNAL m_count : INTEGER;

BEGIN

	PROCESS (CLOCK_50)
	BEGIN
		IF (rising_edge(CLOCK_50)) THEN

			-------------------------------------
			-- Counter Functionality
			-------------------------------------
			-- Reset actions
			IF (RESET_N = '1') THEN
				-- reset the counters
				f_count <= memclk_div;
				b_count <= bits_in_byte;
				m_count <= message_bytes;
				w_count <= bytes_in_chip;
				
				-- load the shift register
				sr    <= sin_startread;
				-- not running yet - need to setup mode first
				running <= '0';
				-- reset the outputs to an appropriate state
				SCK    <= '0';
				si_out <= '0';

			-- Just do nothing at the end, wait for the next reset
			ELSIF (w_count = 0) THEN

			-- Update reference counters at the end of each bit
			ELSIF (f_count = 0) THEN
				f_count <= memclk_div; -- always reset frquency divider
				IF (b_count = 0) THEN
					b_count <= bits_in_byte; -- reset bit counter at end of word
					IF (m_count = 0) THEN
						-- once first mode message set we are 'running'
						running <= '1';
						-- wont't happen first time
						IF (running = 1) THEN
							w_count <= w_count - 1;
						END IF;
					ELSE
						m_count <= m_count - 1;
					END IF;
				ELSE
					b_count <= b_count - 1;
				END IF;

			-- If not the end of a bit, keep decrementing frequency divider
			ELSE
				f_count <= f_count - 1;
			END IF;

			------------------------------------------------
			-- Output generation functionality
			------------------------------------------------

			-- Generate SCK, should rise in the middle of the f_count
			IF (f_count < (memclk_div / 2) ) THEN
				SCLK <= '1';
			ELSIF (f_count > (memclk_div / 2)) THEN
				SCLK <= '0';
			END IF;
			
			
			
			-- TODO - work out how to scan each memory byte in turn...
			
			-- Output Instructions on first 3 bytes of a message
			IF (m_count /= 0) THEN
				-- Generate serial data output
				sr <= sr((3*8-2) DOWNTO 0) & '0' ; -- Shift the Shift Register
				sdout <= sr(3*8-1); -- Output the first bit on the shift register	
			-- Last byte of message - receive data if runng
			ELSIF (running = '1') THEN
				-- Put next memory address instruction into shift register
				sr <= sin_read & std_logic_vector(to_unsigned(w_count, 16));
				-- TODO: READ memory output byte
				
			END IF;
				
			

		END IF;
    
    SIN <= si_out; 			
    
	END PROCESS;
				
END rtl;