LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY PRBS_tbv IS
END PRBS_tbv;
 
ARCHITECTURE behavior OF PRBS_tbv IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT PBRS_generator
    PORT(
         PATTERN : OUT  std_logic_vector(3 downto 0);
         CLOCK   : IN   std_logic
        );
    END COMPONENT;
 
   --Inputs
   signal CLOCK   : std_logic := '0';
 	--Outputs
   signal PATTERN : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 40 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PBRS_generator PORT MAP (PATTERN => PATTERN, CLOCK => CLOCK);

   -- Clock process definitions
   clocker :process
	  constant total_clksteps : integer := 1000;
   begin
		wait for 100ns; -- wait for possible global reset
		for clksteps in 0 to (total_clksteps) loop
			CLOCK <= '0';
			wait for CLOCK_period/2;
			CLOCK <= '1';
			wait for CLOCK_period/2;
		end loop;
		wait;
   end process;
 
END;
