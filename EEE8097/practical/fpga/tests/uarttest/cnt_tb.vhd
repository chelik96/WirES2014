library ieee;
use ieee.std_logic_1164.all;
 
entity cnt_tb is
end cnt_tb;
 
architecture arch of cnt_tb is

  -- unit under test
  component cnt
  port(
    rst : in  std_logic;
    clk : in  std_logic;
    ovf : out std_logic
  );
  end component;

  -- inputs & outputs
  signal rst : std_logic := '0';
  signal clk : std_logic := '0';
  signal ovf : std_logic;

  -- clock period
  constant clk_period : time := 10 ns;

begin

  uut: cnt port map (rst, clk, ovf);

  -- clock process
  clk_process: process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- stimulus process
  stim_proc: process
  begin		
    -- wait a bit then reset - should start counting.
    wait for clk_period * 10;	
    rst <= '1';
    wait for clk_period;
    rst <= '0';
    wait;
  end process;

end;