library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity uarttest is
	port(
		sw     : in std_logic_vector (9 downto 3); 
      clk    : in std_logic;
		uartclk: in std_logic;
		rst_n  : in std_logic;
      tx    : out std_logic
	);
end uarttest;

architecture rtl of uarttest is

	type states  is (idle, start_bit, data_bit, end_bit);
	
begin

	process(clk)
		variable state  : states  := idle;
		variable d_pos  : integer := 7;
	begin	
		if rising_edge(clk) then
			-- handle a reset - go back to idle mode
			if rst_n  = '1' then
				tx    <= '1';
				state := idle;
				d_pos := 8;
			elsif rising_edge(uartclk) then
				case state is
					when idle =>
						
					when starting =>
						txd <= '1';
					when sending  =>
					
					when ending   =>
						tx <= '0';
						state := idling;
				end case;

			end if;
		end if;
	end process;
	
end rtl;