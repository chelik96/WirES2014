LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.all;

ENTITY fir_filter IS
	GENERIC (

		CONSTANT MSB_Audio : NATURAL := 15;
		CONSTANT Taps      : NATURAL := 8
	);
	PORT (
		ADCDAT : IN  STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
		DACDAT : OUT STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
		DACrdy : IN  STD_LOGIC;
		ADCrdy : OUT STD_LOGIC;
		DACstb : OUT STD_LOGIC;
		ADCstb : IN  STD_LOGIC;
		-- Control Signals
		CLOCK_50: IN  STD_LOGIC;
		RST_N  : IN  STD_LOGIC
	);
END ENTITY;

ARCHITECTURE rtl OF fir_filter IS
   TYPE Coeffs_Type IS ARRAY ((Taps-1) DOWNTO 0) OF STD_LOGIC_VECTOR(MSB_AUDIO DOWNTO 0); 
	CONSTANT Coeffs : Coeffs_Type := (
		b"1111101100010100", b"0001111010010011", b"0011000010110111", b"0100000000000000",
		b"0100000000000000", b"0011000010110111", b"0001111010010011", b"1111101100010100"); 
	
	TYPE Delay_Line IS ARRAY ((Taps - 2) DOWNTO 0) OF STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
	SIGNAL FIR_Delay : Delay_Line;
	SIGNAL OLD_ADCstb: STD_LOGIC;
	SIGNAL Accumulator: STD_LOGIC_VECTOR(34 DOWNTO 0) := (OTHERS => '0');
BEGIN

	main : PROCESS (CLOCK_50)
		VARIABLE Multiply_Step : INTEGER := 7;
		VARIABLE i             : INTEGER;
	BEGIN
		IF (rising_edge(CLOCK_50)) THEN
			OLD_ADCstb <= ADCstb;
			-- Reset actions
			IF (RST_N = '0') THEN
				DACstb <= '0';
				ADCrdy <= '0';
				DACDAT <= b"0000000000000000";
				Multiply_Step := 7;
				FOR i IN FIR_Delay'RANGE LOOP
					FIR_Delay(i) <= (OTHERS => '0');
				END LOOP;
			ELSE
				ADCrdy <= '1';
				IF (old_ADCstb='0' and ADCstb='1') THEN
					-- Shift the Delay Line by One sample
					Fir_Delay(6) <= ADCDAT;  -- Eight tap FIR_Filter (0-7)
					Fir_Delay(5 DOWNTO 0) <= Fir_Delay(6 DOWNTO 1);
					-- Process the current input, multiply by first coeff and place in accumulator
					Multiply_Step := 7;
					Accumulator(31 DOWNTO 0)  <= (ADCDAT * Coeffs(Multiply_step));
					Accumulator(34 DOWNTO 32) <= (others => '0');
					DACstb <= '0';
				-- Multiply Delay line registers by their corrseponding coeffs 
				ELSIF (Multiply_Step > 0) THEN
					Multiply_step := Multiply_Step - 1;
					Accumulator  <= (Accumulator+(Fir_Delay(Multiply_step)*Coeffs(Multiply_step)));
					DACDAT <= Accumulator(31 DOWNTO 16);
					IF (Multiply_Step = 0) THEN
						DACstb <= '1';
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS main;

END rtl;