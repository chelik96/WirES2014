LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
 
ENTITY counter_tbv IS
END counter_tbv;
 
ARCHITECTURE behavior OF counter_tbv IS 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT counter
    PORT(
         CLOCK : IN  std_logic;
         DIRECTION : IN  std_logic;
         COUNT_OUT : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
   --Inputs
   signal CLOCK : std_logic := '0';
   signal DIRECTION : std_logic := '0';
 	--Outputs
   signal COUNT_OUT : std_logic_vector(3 downto 0);
   -- Clock period definitions
   constant CLOCK_period : time := 40 ns;
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: counter PORT MAP (CLOCK, DIRECTION, COUNT_OUT);
   -- Clock process definitions
   CLOCK_process :process
   begin
		-- wait 100 ns for global reset to finish
		WAIT for 100 ns;
		CLOCK_LOOP : LOOP
			CLOCK <= '0';
			WAIT FOR CLOCK_period/2;
			CLOCK <= '1';
			WAIT FOR CLOCK_period/2;
		END LOOP CLOCK_LOOP;
   end process;
   -- Direction process
   tb: process
   begin		
      -- hold reset state for 300 ns.
      wait for 300 ns;
      -- insert stimulus here 
		DIRECTION <='1';
		wait for 608 ns;
		DIRECTION <= '0';
      wait;
   end process;
END;
