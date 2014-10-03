LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY stereo_s2p_adaptor_vhd_tst IS
	GENERIC (
		CONSTANT MSB_Audio: NATURAL := 15
	);
END stereo_s2p_adaptor_vhd_tst;
ARCHITECTURE stereo_s2p_adaptor_arch OF stereo_s2p_adaptor_vhd_tst IS	
	-- Left Channel Interface (Parallel)
	SIGNAL L_ADCDAT: STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
	SIGNAL L_DACDAT: STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
	SIGNAL L_DACrdy: STD_LOGIC;
	SIGNAL L_ADCrdy: STD_LOGIC;
	SIGNAL L_DACstb: STD_LOGIC;
	SIGNAL L_ADCstb: STD_LOGIC;
	-- Right Channel Interface (Parallel)
	SIGNAL R_ADCDAT: STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
	SIGNAL R_DACDAT: STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
	SIGNAL R_DACrdy: STD_LOGIC;
	SIGNAL R_ADCrdy: STD_LOGIC;
	SIGNAL R_DACstb: STD_LOGIC;
	SIGNAL R_ADCstb: STD_LOGIC;
	
	SIGNAL AUD_DACDAT:  STD_LOGIC;
	SIGNAL AUD_ADCDAT:  STD_LOGIC;
	SIGNAL AUD_ADCLRCK: STD_LOGIC;
	SIGNAL AUD_DACLRCK: STD_LOGIC;
	SIGNAL AUD_BCLK:    STD_LOGIC;
	SIGNAL CLOCK_50:    STD_LOGIC;
	SIGNAL RST_N:       STD_LOGIC;
COMPONENT stereo_s2p_adaptor
	PORT (
		L_ADCDAT:     OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		L_DACDAT:    IN  STD_LOGIC_VECTOR(15 DOWNTO 0);	
		L_DACrdy:    OUT STD_LOGIC;
		L_ADCrdy:    IN  STD_LOGIC;
		L_DACstb:    IN  STD_LOGIC;
		L_ADCstb:    OUT STD_LOGIC;
		R_ADCDAT:    OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		R_DACDAT:    IN  STD_LOGIC_VECTOR(15 DOWNTO 0);	
		R_DACrdy:    OUT STD_LOGIC;
		R_ADCrdy:    IN  STD_LOGIC;
		R_DACstb:    IN  STD_LOGIC;
		R_ADCstb:    OUT STD_LOGIC;
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
	test_stereo_s2p_adaptor : stereo_s2p_adaptor PORT MAP (
		L_ADCDAT, L_DACDAT, L_DACrdy, L_ADCrdy, L_DACstb, L_ADCstb,
		R_ADCDAT, R_DACDAT, R_DACrdy, R_ADCrdy, R_DACstb, R_ADCstb,
		AUD_DACDAT, AUD_ADCDAT, AUD_ADCLRCK, AUD_DACLRCK, AUD_BCLK,
		CLOCK_50, RST_N
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
		L_DACDAT <= b"0011010100011110";
		L_DACstb <= '0';
		L_ADCrdy <= '1';
		R_DACDAT <= b"0011010100011110";
		R_DACstb <= '0';
		R_ADCrdy <= '1';
		WAIT FOR 1000 ns;
		FOR steps IN 0 TO total_strobes LOOP
			WAIT FOR 12755 ns; -- 354.xxx * 36
			L_DACstb <= '1';
			R_DACstb <= '1';
			WAIT FOR 2126 ns; -- 354.xxx * 6
			L_DACstb <= '0';
			R_DACstb <= '0';
			WAIT FOR 7794 ns; -- remaining time: 22675-(12755+2126)
		END LOOP;
		WAIT;
	END PROCESS coredata;
	
	codecdata : PROCESS
		CONSTANT total_pulses : INTEGER := 3;
	BEGIN
		AUD_ADCDAT <= '1';
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
	END PROCESS codecdata;
	
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

END stereo_s2p_adaptor_arch;