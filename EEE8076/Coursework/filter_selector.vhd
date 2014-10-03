LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY filter_selector IS
	GENERIC (
		CONSTANT MSB_Audio : NATURAL := 15
	);
	PORT 
	(
		-- Control Toggle Lines
		MUTE_BTN  : IN STD_LOGIC;
		FILT_BTN  : IN STD_LOGIC;
	   -- LED State Lines
	   MUTE_STATE: OUT STD_LOGIC;
	   FILT_STATE: OUT STD_LOGIC;
		-- Data Lines to Control
		ADCDAT_IN : IN  STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
		DACDAT_IN : IN  STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
		DACDAT_OUT: OUT STD_LOGIC_VECTOR(MSB_Audio DOWNTO 0);
		-- Control Signals
		CLOCK_50  : IN  STD_LOGIC; -- master clock
		RST_N     : IN  STD_LOGIC -- reset, active 0
	);
END ENTITY;

ARCHITECTURE behaviour OF filter_selector IS
	SIGNAL LAST_MUTE_BTN : STD_LOGIC := '1';
   SIGNAL LAST_FILT_BTN : STD_LOGIC := '1';
	SIGNAL CUR_MUTE_STATE: STD_LOGIC := '0';    -- CUR is "Current" not "I" ;)
	SIGNAL CUR_FILT_STATE: STD_LOGIC := '1';
BEGIN

	PROCESS (CLOCK_50)
	BEGIN
		IF (RISING_EDGE(CLOCK_50)) THEN
			IF (RST_N = '0') THEN
				-- reset to default connections - passthru everything to filter
				LAST_MUTE_BTN  <= '1';
				LAST_FILT_BTN  <= '1';
				CUR_MUTE_STATE <= '0';
				CUR_FILT_STATE <= '1';
				MUTE_STATE     <= '0';
			   FILT_STATE     <= '1';
				DACDAT_OUT     <= DACDAT_IN;
				
			-- Toggle states on falling edge (buttons default to high when not pressed)
			ELSIF (MUTE_BTN = '0' AND LAST_MUTE_BTN = '1') THEN
				CUR_MUTE_STATE <= NOT CUR_MUTE_STATE;
				MUTE_STATE <= CUR_MUTE_STATE;
			ELSIF (FILT_BTN = '0' AND LAST_FILT_BTN = '1') THEN
				CUR_FILT_STATE <= NOT CUR_FILT_STATE;
				FILT_STATE <= NOT CUR_FILT_STATE;
			END IF;
			
			-- Now process exisiting state to decide how to connect inputs to outputs
			-- three options: mute/unfiltered/filtered
			IF (CUR_MUTE_STATE = '1') THEN
				DACDAT_OUT <= (OTHERS => '0');
			ELSIF (CUR_FILT_STATE = '0') THEN
				DACDAT_OUT <= ADCDAT_IN;
			ELSE
				DACDAT_OUT <= DACDAT_IN;
			END IF;
			
			-- Record Current Button states for next time	  
			LAST_MUTE_BTN <= MUTE_BTN;
			LAST_FILT_BTN <= FILT_BTN;
		END IF;
		
	END PROCESS;			
END behaviour;