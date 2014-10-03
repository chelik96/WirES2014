LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY stereo_s2p_adaptor IS
	GENERIC (
		CONSTANT MSB_Audio: NATURAL := 15
	);
	PORT (
		-- Left Channel Interface (Parallel)
		L_ADCDAT:    OUT STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
		L_DACDAT:    IN  STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
		L_DACrdy:    OUT STD_LOGIC;
		L_ADCrdy:    IN  STD_LOGIC;
		L_DACstb:    IN  STD_LOGIC;
		L_ADCstb:    OUT STD_LOGIC;
		-- Right Channel Interface (Parallel)
		R_ADCDAT:    OUT STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
		R_DACDAT:    IN  STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
		R_DACrdy:    OUT STD_LOGIC;
		R_ADCrdy:    IN  STD_LOGIC;
		R_DACstb:    IN  STD_LOGIC;
		R_ADCstb:    OUT STD_LOGIC;		
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

ARCHITECTURE rtl OF stereo_s2p_adaptor IS
	SIGNAL old_BCLK: STD_LOGIC;
	SIGNAL L_DACREG: STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
	SIGNAL R_DACREG: STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
BEGIN

	main : PROCESS (CLOCK_50)
		VARIABLE L_bit_ADC: INTEGER;
		VARIABLE L_bit_DAC: INTEGER;
		VARIABLE R_bit_ADC: INTEGER;
		VARIABLE R_bit_DAC: INTEGER;
	BEGIN
		IF (rising_edge(CLOCK_50)) THEN
			-- Reset actions
			IF (RST_N = '0') THEN
				AUD_DACDAT <= '0';
				L_ADCstb  <= '0';
				L_DACrdy  <= '0';
				R_ADCstb  <= '0';
				R_DACrdy  <= '0';
				L_bit_ADC := MSB_Audio;
				L_bit_DAC := MSB_Audio;
				R_bit_ADC := MSB_Audio;
				R_bit_DAC := MSB_Audio;
			ELSE
				old_BCLK <= AUD_BCLK; -- needed for change detection on BCLK input
				L_DACrdy <= '1';        -- Always OK to receive data if not reset
				R_DACrdy <= '1';        -- Always OK to receive data if not reset
				-------------------------------------------------------------------
				-- Input channel
				-------------------------------------------------------------------
				-- On a rising edge of the bclk we grab data from the dacdat line
				IF (old_BCLK='0' and AUD_BCLK='1') THEN
					-- Start of serial data in: Restart counters and read first left bit
					IF (AUD_ADCLRCK = '1') THEN
						L_bit_ADC := MSB_Audio;
						L_ADCDAT(L_bit_ADC) <= AUD_ADCDAT;
						L_ADCstb <= '0';
					-- Other left channel serial data bits: Read bits & Update count
					ELSIF (L_bit_ADC > 0) THEN
						L_bit_ADC := L_bit_ADC - 1;
						L_ADCDAT(L_bit_ADC) <= AUD_ADCDAT;
						-- Strobe to filter and start on right channel when all left bits received
						IF (L_bit_ADC = 0) THEN
							L_ADCstb <= '1';
							R_bit_ADC := MSB_Audio;
							R_ADCstb <= '0';
						END IF;
					-- Now handle the right channel in the roughly the same way as the left...
					ELSIF (R_bit_ADC >= 0) THEN
						R_ADCDAT(R_bit_ADC) <= AUD_ADCDAT;
						IF (R_bit_ADC = 0) THEN
							R_ADCstb <= '1';
						END IF;
						R_bit_ADC := R_bit_ADC -1;
					END IF;	
				END IF;

				-------------------------------------------------------------------
				-- Output channel
				-------------------------------------------------------------------
				-- Start of a new sample: reset counters, send out first bit
				IF (AUD_DACLRCK = '1') THEN
					L_bit_DAC := MSB_Audio;
					AUD_DACDAT <= L_DACREG(L_bit_DAC);
				-- Other left channel serial data bits: Send bits and Update count
				ELSIF (old_BCLK='1' and AUD_BCLK='0' and L_bit_DAC > 0) THEN
					L_bit_DAC := L_bit_DAC - 1; -- produce DAC serial data bit
					AUD_DACDAT <= L_DACREG(L_bit_DAC);
					-- once finished with left channel, start on the right next blck
					IF (L_bit_DAC = 0) THEN
						R_bit_DAC := MSB_Audio;
					END IF;
				-- Right channel after the left in the same way
				ELSIF (old_BCLK='1' and AUD_BCLK='0' and R_bit_DAC > 0) THEN
					R_bit_DAC := R_bit_DAC - 1; -- produce DAC serial data bit
					AUD_DACDAT <= R_DACREG(R_bit_DAC);
				-- Keep output low when not sending data - cleaner on signal tap.
				ELSIF (old_BCLK='1' and AUD_BCLK='0' and R_bit_DAC = 0 and L_bit_DAC = 0) THEN
						AUD_DACDAT <= '0';
				END IF;
				
				-- Load parallel register when filter ready & not sending previous
				IF (L_DACstb = '1' and L_bit_DAC = 0) THEN
					L_DACREG <= L_DACDAT;
				END IF;
				IF (R_DACstb = '1' and R_bit_DAC = 0) THEN
					R_DACREG <= R_DACDAT;
				END IF;
			END IF;
		END IF;
	END PROCESS main;
END rtl;