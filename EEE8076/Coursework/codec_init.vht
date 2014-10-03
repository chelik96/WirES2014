LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY codec_init_vhd_tst IS
END codec_init_vhd_tst;
ARCHITECTURE codec_init_arch OF codec_init_vhd_tst IS
	SIGNAL CLOCK_50 : STD_LOGIC;
	SIGNAL RES_N    : STD_LOGIC;
	SIGNAL SCLK     : STD_LOGIC;
	SIGNAL SDIN     : STD_LOGIC;
	COMPONENT codec_init
		PORT (
			CLOCK_50 : IN  STD_LOGIC;
			RES_N    : IN  STD_LOGIC;
			SCLK     : OUT STD_LOGIC;
			SDIN     : OUT STD_LOGIC
		);
	END COMPONENT;
BEGIN

	test_codec_init : codec_init PORT MAP (CLOCK_50, RES_N, SCLK, SDIN);

	testinputs : PROCESS
	BEGIN
		RES_N <= '0'; -- reset initialization system
		WAIT FOR 200 ns;
		RES_N <= '1'; -- start sending initialization data
		WAIT;
	END PROCESS testinputs;

	clock : PROCESS
		-- 11 words * 29 bits * 500 clocks-per-bit + some extra
		CONSTANT total_clksteps : INTEGER := 165000;
	BEGIN
		CLOCK_50 <= '0';
		FOR clksteps IN 0 TO (total_clksteps*2) LOOP
			WAIT FOR 10 ns;
			CLOCK_50 <= NOT CLOCK_50;
		END LOOP;
		WAIT;
	END PROCESS clock;

END codec_init_arch;