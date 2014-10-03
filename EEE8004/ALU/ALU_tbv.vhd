LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY ALU_tbv IS
END ALU_tbv;
 
ARCHITECTURE behavior OF ALU_tbv IS 

    COMPONENT ALU
    PORT(
         CLOCK : IN  std_logic;
         F : IN  std_logic_vector(1 downto 0);
         A : IN  std_logic_vector(3 downto 0);
         B : IN  std_logic_vector(3 downto 0);
         O : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;

   --Inputs
   signal CLOCK : std_logic := '0';
   signal F : std_logic_vector(1 downto 0) := (others => '0');
   signal A : std_logic_vector(3 downto 0) := (others => '0');
   signal B : std_logic_vector(3 downto 0) := (others => '0');
 	--Outputs
   signal O : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant CLOCK_period : time := 10 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (CLOCK => CLOCK, F => F, A => A, B => B, O => O);

   -- Clock process definitions
   CLOCK_process :process
   begin
		CLOCK <= '0';
		wait for CLOCK_period/2;
		CLOCK <= '1';
		wait for CLOCK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
		constant total_tests : integer := 1000;
   begin		
      -- hold reset state for 100 ns.
		A <= "0000";
		B <= "0000";
		F <= "00";
      wait for 100 ns;	
		for test in 0 to (total_tests) loop
			F <= "00";
			wait for CLOCK_period*2;
			F <= "01";
			wait for CLOCK_period*2;
			F <= "10";
			wait for CLOCK_period*2;
			F <= "11";
			wait for CLOCK_period*2;
			A <= A + 1;
			if (test mod 4 = 0) then
				B <= B + 1;
			end if;
		end loop;
      wait;
   end process;

END;
