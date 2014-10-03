library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PBRS_generator is
    Port (
		PATTERN : out  STD_LOGIC_VECTOR (3 downto 0);
      CLOCK   : in   STD_LOGIC);
end PBRS_generator;

architecture Behavioral of PBRS_generator is
	signal sr: std_logic_vector (3 downto 0) := b"1000";
begin
	main : process (CLOCK)
	begin
		-- Output the current values
		PATTERN <= sr;
		--process the feedback loops
		sr(3) <= sr(3) xor sr(0);
		sr(2 downto 0) <= sr(3 downto 1);
	end process;
	
end Behavioral;