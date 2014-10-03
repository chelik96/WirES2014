library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity clock_divider is 
	port(
		n_rst   : in  std_logic;
	   clk     : in  std_logic;
	   uartclk : out std_logic
	);
end clock_divider;

architecture rtl of clock_divider is

	constant nil_24bit : unsigned (23 downto 0) := "000000000000000000000000";
	constant one_24bit : unsigned (23 downto 0) := "000000000000000000000001";
	-- need to determine exact value (nb. Main clock 50Mhz, uartclk should be 9.6kHz)
	constant div_24bit : unsigned (23 downto 0) := "000000000000101000101100";
	
	
	signal clk_val : std_logic;
	signal acc     : unsigned (23 downto 0);
	
begin

	process(n_rst, clk)
	begin
		-- handle a reset
		if ( n_rst = '0' ) then
			clk_val <= '0';
			acc     <= nil_24bit;
		-- trigger on rising edge of clock
		elsif ( clk'event and clk = '1' ) then
			if( acc = div_24bit ) then
				-- toggle uart clock
				clk_val <= not clk_val;
				-- reset accumulator
				acc <= nil_24bit;
			else
				acc <= acc + one_24bit;
			end if;
		end if;
	end process;
	
	uartclk <= clk_val;
	
end rtl;