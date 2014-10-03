library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ALU is
	Port (
		CLOCK : in  STD_LOGIC;
		F: in  STD_LOGIC_VECTOR (1 downto 0);
		A: in  STD_LOGIC_VECTOR (3 downto 0);
		B: in  STD_LOGIC_VECTOR (3 downto 0);
		O: out STD_LOGIC_VECTOR (3 downto 0)
	);
end ALU;

architecture Behavioral of ALU is
begin
	main: PROCESS (CLOCK)
	begin
		case F is
			when "00" => O <= A + B;
			when "01" => O <= A - B;
			when "10" => O <= A - 1;
			when "11" => O <= B - 1;
			when others => null;
		end case;
	end process main;
end Behavioral;

