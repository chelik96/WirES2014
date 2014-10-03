-- modified into a 10 bit PBRS for combined testing purposes (ALU needs 10 input bits - 2x4 bit inputs and 2 more for mode select)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PBRS_generator is
	generic (
		MSB : integer := 9
	);
   port (
		PATTERN : out  STD_LOGIC_VECTOR (MSB downto 0);
      CLOCK   : in   STD_LOGIC);
end PBRS_generator;

architecture Behavioral of PBRS_generator is
	signal sr: std_logic_vector (MSB downto 0) := b"1111111111";
begin
	main : process (CLOCK)
	begin
		-- Output the current values
		PATTERN <= sr;
		--process the feedback loops
		sr(MSB) <= sr(3) xor sr(0);
		sr(MSB - 1 downto 0) <= sr(MSB downto 1);
	end process;
end Behavioral;