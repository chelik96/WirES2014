LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY s2p_adaptor IS
	GENERIC (
		CONSTANT MSB_Audio: NATURAL := 15
	);
	PORT (
		-- FILTER Interface (Parallel)
		ADCDAT:      OUT STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
		DACDAT:      IN  STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
		DACrdy:      OUT STD_LOGIC;
		ADCrdy:      IN  STD_LOGIC;
		DACstb:      IN  STD_LOGIC;
		ADCstb:      OUT STD_LOGIC;
		-- CODEC Interface (Serial)
		AUD_DACDAT:  OUT STD_LOGIC; -- serial data out
		AUD_ADCDAT:  IN  STD_LOGIC; -- serial data in
		AUD_ADCLRCK: IN  STD_LOGIC; -- strobe for input
		AUD_DACLRCK: IN  STD_LOGIC; -- strobe for output
		AUD_BCLK:    IN  STD_LOGIC; -- serial interface "clock"
		-- Control Signals
		CLOCK_50:    IN  STD_LOGIC;
		RST_N:       IN  STD_LOGIC
	);
END ENTITY;

ARCHITECTURE rtl OF s2p_adaptor IS
	SIGNAL old_BCLK: STD_LOGIC;
	SIGNAL DACREG  : STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
BEGIN

	main : PROCESS (CLOCK_50)
		VARIABLE bit_ADC: INTEGER;
		VARIABLE bit_DAC: INTEGER;
	BEGIN
		IF (rising_edge(CLOCK_50)) THEN
			-- Reset actions
			IF (RST_N = '0') THEN
				AUD_DACDAT <= '0';
				ADCstb  <= '0';
				DACrdy  <= '0';
				bit_ADC := MSB_Audio;
				bit_DAC := MSB_Audio;
			ELSE
				old_BCLK <= AUD_BCLK; -- needed for change detection on BCLK input
				DACrdy <= '1';        -- Always OK to receive data if not reset
				-------------------------------------------------------------------
				-- Input channel
				-------------------------------------------------------------------
				-- On a rising edge of the bclk we grab data from the dacdat line
				IF (old_BCLK='0' and AUD_BCLK='1') THEN
					-- Start of serial data in: Restart counter and read first bit
					IF (AUD_ADCLRCK = '1') THEN
						bit_ADC := MSB_Audio;
						ADCDAT(bit_ADC) <= AUD_ADCDAT;
						ADCstb <= '0';
					-- Other left channel serial data bits: Read bits & Update count
					ELSIF (bit_ADC > 0) THEN
						bit_ADC := bit_ADC - 1;
						ADCDAT(bit_ADC) <= AUD_ADCDAT;
						-- Strobe to filter when all data bits received
						IF (bit_ADC = 0) THEN
							ADCstb <= '1';
						END IF;
					END IF;	
				END IF;

				-------------------------------------------------------------------
				-- Output channel
				-------------------------------------------------------------------
				-- Start of a new sample: reset counters, send out first bit
				IF (AUD_DACLRCK = '1') THEN
					bit_DAC := MSB_Audio;
					AUD_DACDAT <= DACREG(bit_DAC);
				-- Other left channel serial data bits: Send bits and Update count
				ELSIF (old_BCLK='1' and AUD_BCLK='0' and bit_DAC > 0) THEN
					bit_DAC := bit_DAC - 1; -- produce DAC serial data bit
					AUD_DACDAT <= DACREG(bit_DAC);
				-- Keep output low when not sending data - cleaner on signal tap.
				ELSIF (bit_DAC = 0) THEN
					AUD_DACDAT <= '0';
				END IF;
				-- Load parallel register when filter ready & not sending previous
				IF (DACstb = '1' and bit_DAC = 0) THEN
					DACREG <= DACDAT;
				END IF;
			END IF;
		END IF;
	END PROCESS main;
END rtl;