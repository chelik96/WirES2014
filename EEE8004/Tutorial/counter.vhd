library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter is
    Port ( CLOCK : in  STD_LOGIC;
           DIRECTION : in  STD_LOGIC;
           COUNT_OUT : out  STD_LOGIC_VECTOR (3 downto 0));
end counter;

architecture Behavioral of counter is
	signal cnt_int : std_logic_vector(3 downto 0) := "0000";
begin
	process (CLOCK)
	begin
		if CLOCK = '1' and CLOCK'event then
			if DIRECTION = '1' then
				cnt_int <= cnt_int + 1;
			else
				cnt_int <= cnt_int - 1;
			end if;
		end if;
	end process;
	COUNT_OUT <= cnt_int;
end Behavioral;

