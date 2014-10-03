LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY fir_filter_vhd_tst IS
	GENERIC (
		CONSTANT MSB_Audio: NATURAL := 15
	);
END fir_filter_vhd_tst;
ARCHITECTURE fir_filter_arch OF fir_filter_vhd_tst IS
	SIGNAL ADCDAT : STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
	SIGNAL DACDAT : STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
	SIGNAL DACrdy : STD_LOGIC;
	SIGNAL ADCrdy : STD_LOGIC;
	SIGNAL DACstb : STD_LOGIC;
	SIGNAL ADCstb : STD_LOGIC;
	SIGNAL CLOCK_50:STD_LOGIC;
	SIGNAL RST_N  : STD_LOGIC;
	COMPONENT fir_filter
		PORT (
			ADCDAT : IN  STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
			DACDAT : OUT STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
			DACrdy : IN  STD_LOGIC;
			ADCrdy : OUT STD_LOGIC;
			DACstb : OUT STD_LOGIC;
			ADCstb : IN  STD_LOGIC;
			CLOCK_50: IN  STD_LOGIC;
			RST_N  : IN  STD_LOGIC
		);
END COMPONENT;

BEGIN
	test_fir_filter : fir_filter PORT MAP (
		ADCDAT, DACDAT, DACrdy, ADCrdy,
		DACstb, ADCstb, CLOCK_50, RST_N
	);

	-- reset at the start of test for a reasonable amount of time
	reset : PROCESS
	BEGIN
		RST_N <= '0';
		WAIT FOR 1000 ns;
		RST_N <= '1';
		WAIT;
	END PROCESS reset;

	-- total time of one bclk = 354.30839
	-- number of bclks between each timing pulse
	-- total time between timing pulses: ~22675ns
	
	coredata : PROCESS
	  CONSTANT total_strobes : INTEGER := 20;
	BEGIN
		ADCDAT <= b"0011010100011110";
		ADCstb <= '0';
		DACrdy <= '1';
		WAIT FOR 1000 ns;
		FOR steps IN 0 TO total_strobes LOOP
			WAIT FOR 12755 ns; -- 354.xxx * 36
			ADCstb <= '1';
			WAIT FOR 2126 ns; -- 354.xxx * 6
			ADCstb <= '0';
			WAIT FOR 7794 ns; -- remaining time: 22675-(12755+2126)
		END LOOP;
		WAIT;
	END PROCESS coredata;

	clock : PROCESS
		CONSTANT total_clksteps : INTEGER := 25000;
	BEGIN
		FOR clksteps IN 0 TO total_clksteps LOOP
			CLOCK_50 <= '0';
			WAIT FOR 10 ns;
			CLOCK_50 <= '1';
			WAIT FOR 10 ns;
		END LOOP;
	WAIT;
	END PROCESS clock;

END fir_filter_arch;