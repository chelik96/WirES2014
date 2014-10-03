LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY s2p_adaptor_vhd_tst IS
	GENERIC (
		CONSTANT MSB_Audio: NATURAL := 15
	);
END s2p_adaptor_vhd_tst;
ARCHITECTURE s2p_adaptor_arch OF s2p_adaptor_vhd_tst IS
	SIGNAL ADCDAT:      STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
	SIGNAL DACDAT:      STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
	SIGNAL DACrdy:      STD_LOGIC;
	SIGNAL ADCrdy:      STD_LOGIC;
	SIGNAL DACstb:      STD_LOGIC;
	SIGNAL ADCstb:      STD_LOGIC;
	SIGNAL AUD_DACDAT:  STD_LOGIC;
	SIGNAL AUD_ADCDAT:  STD_LOGIC;
	SIGNAL AUD_ADCLRCK: STD_LOGIC;
	SIGNAL AUD_DACLRCK: STD_LOGIC;
	SIGNAL AUD_BCLK:    STD_LOGIC;
	SIGNAL CLOCK_50:    STD_LOGIC;
	SIGNAL RST_N:       STD_LOGIC;
COMPONENT s2p_adaptor
	PORT (
		ADCDAT:      OUT STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
		DACDAT:      IN  STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);	
		DACrdy:      OUT STD_LOGIC;
		ADCrdy:      IN  STD_LOGIC;
		DACstb:      IN  STD_LOGIC;
		ADCstb:      OUT STD_LOGIC;
		AUD_DACDAT:  OUT STD_LOGIC;
		AUD_ADCDAT:  IN  STD_LOGIC;
		AUD_ADCLRCK: IN  STD_LOGIC;
		AUD_DACLRCK: IN  STD_LOGIC;
		AUD_BCLK:    IN  STD_LOGIC;
		CLOCK_50:    IN  STD_LOGIC;
		RST_N:       IN  STD_LOGIC
	);
END COMPONENT;

BEGIN
	test_s2p_adaptor : s2p_adaptor PORT MAP (
		ADCDAT, DACDAT, DACrdy, ADCrdy, DACstb, ADCstb,
		AUD_DACDAT, AUD_ADCDAT, AUD_ADCLRCK, AUD_DACLRCK,
		AUD_BCLK, CLOCK_50, RST_N
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
	
	
	-- should go high a little after 32 cycles of the bclock - say 36 bits...
	-- then back down after a few more bclock pulses - say 6 bits...
	coredata : PROCESS
	  CONSTANT total_strobes : INTEGER := 3;
	BEGIN
		DACDAT <= b"0011010100011110";
		DACstb <= '0';
		ADCrdy <= '1';
		WAIT FOR 1000 ns;
		FOR steps IN 0 TO total_strobes LOOP
			WAIT FOR 12755 ns; -- 354.xxx * 36
			DACstb <= '1';
			WAIT FOR 2126 ns; -- 354.xxx * 6
			DACstb <= '0';
			WAIT FOR 7794 ns; -- remaining time: 22675-(12755+2126)
		END LOOP;
		WAIT;
	END PROCESS coredata;
	
	codecdata : PROCESS
		CONSTANT i : INTEGER := 46;
	BEGIN
		AUD_ADCDAT <= '1';
		WAIT FOR 1000 ns;
		FOR steps IN 0 TO i LOOP
			AUD_ADCDAT <= '1';
			WAIT FOR 1000 ns;
			AUD_ADCDAT <= '0';
			WAIT FOR 1000 ns;
		END LOOP;
		WAIT;
	END PROCESS codecdata;
	
	codectiming : PROCESS
		CONSTANT total_pulses : INTEGER := 3;
	BEGIN
		AUD_ADCLRCK <= '0';
		AUD_DACLRCK <= '0';
		WAIT FOR 1000 ns;
		FOR steps IN 0 TO total_pulses LOOP
			AUD_ADCLRCK <= '1';
			AUD_DACLRCK <= '1';
			WAIT FOR 354 ns;
			AUD_ADCLRCK <= '0';
			AUD_DACLRCK <= '0';
			WAIT FOR 22302 ns;
		END LOOP;
		WAIT;
	END PROCESS codectiming;
	
	-- BCLK runs at at exactly 2822400 pulses per second
   -- Therefore the duration of each high and low is
	-- 1/2822400*2 = 177.154 nano seconds
	bclock: PROCESS
		CONSTANT total_bclksteps : INTEGER := 255;
	BEGIN
		AUD_BCLK <= '0';
		WAIT FOR 1000 ns;
		FOR steps IN 0 TO total_bclksteps LOOP
			AUD_BCLK <= '0';
			WAIT FOR 177 ns;
			AUD_BCLK <= '1';
			WAIT FOR 177 ns;
		END LOOP;
	WAIT;
	END PROCESS bclock;

	clock : PROCESS
		CONSTANT total_clksteps : INTEGER := 4585;
	BEGIN
		FOR clksteps IN 0 TO total_clksteps LOOP
			CLOCK_50 <= '0';
			WAIT FOR 10 ns;
			CLOCK_50 <= NOT CLOCK_50;
			WAIT FOR 10 ns;
		END LOOP;
	WAIT;
	END PROCESS clock;

END s2p_adaptor_arch;