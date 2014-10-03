library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart1_tb is
end uart1_tb;

architecture rtl of uart1_tb is

  -- uut
  component uart1
  port(
		CLK		: in	std_logic; -- 50MHz
		nRES		: in	std_logic;
		RXD		: in	std_logic; -- 115200 baud, 50M/115200=434
		TXD	   : out	std_logic;
		DR			: out	std_logic_vector (7 downto 0);
		DT			: in	std_logic_vector (7 downto 0);
		STBR		: out	std_logic;
		STBT		: in	std_logic
  );
  end component;
  
  -- inputs & outputs
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  
  signal rxd : std_logic := '1';
  signal txd : std_logic;
  
  signal stbr: std_logic;
  signal stbt: std_logic := '0';
  
  signal dr  : std_logic_vector (7 downto 0);
  signal dt  : std_logic_vector (7 downto 0) := "00000000";
  
  -- clock period
  constant clk_period : time := 10ns;
begin

  uut: uart1 port map (
    CLK  => clk,
	 nRES => rst,
	 RXD  => rxd,
	 TXD  => txd,
	 DR   => dr,
	 DT   => dt,
	 STBR => stbr,
	 STBT => stbt
  );

  -- clock process
  clk_proc: process
  begin
    for I in 0 to 20000 loop
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end loop;
	wait;
  end process;
  
  stim_proc: process
  begin
    -- hold reset for a while to let things settle
	 wait for clk_period * 500;
	 
	 -- release reset (active low) and set first data to send
	 rst  <= '1';
	 
	 -- send first byte ("10101010") at baud rate
	 rxd <= '0'; -- start bit
	 wait for clk_period * 443;
	 rxd <= '1';
	 wait for clk_period * 443;
	 rxd <= '0';
	 wait for clk_period * 443;
	 rxd <= '1';
	 wait for clk_period * 443;
	 rxd <= '0';
	 wait for clk_period * 443;
	 rxd <= '1';
	 wait for clk_period * 443;
	 rxd <= '0';
	 wait for clk_period * 443;
	 rxd <= '1';
	 wait for clk_period * 443;
	 rxd <= '0';
	 wait for clk_period * 443;
	 rxd <= '1'; -- stop bit (and idle)
	 
	 dt   <= "10101010";
	 stbt <= '1';
	 wait for clk_period * 500;
	 stbt <= '0';
	 wait for clk_period * 443 * 10;
	 
	 -- ok now try sending another bit of data
	 dt   <= "00110011";
	 stbt <= '1';
	 wait for clk_period * 500;
	 stbt <= '0';
	 wait for clk_period * 443 * 10;
	 
	 wait;
  end process;
  
end;