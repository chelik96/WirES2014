library ieee;
use ieee.std_logic_1164.all;

entity clk_div_tb IS
end clk_div_tb;
 
architecture arch of clk_div_tb is 

  -- unit under test
  component clk_div
  port(
    clk    : in  std_logic;
    rst    : in  std_logic;
    clk_rx : out std_logic;
    clk_tx : out std_logic
  );
  end component;

  -- inputs & outputs
  signal clk    : std_logic := '0';
  signal rst    : std_logic := '0';
  signal clk_rx : std_logic := '0';
  signal clk_tx : std_logic := '0';
  
  -- clock period (master clock in 50Mhz - 1/50*10^6 - 20*10^-9)
  constant clk_period : time := 20 ns;
  
BEGIN

  uut: clk_div port map (clk, rst, clk_rx, clk_tx);

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
    rst <= '1';
    wait for clk_period * 5000;	
    rst <= '0';
    wait for clk_period * 10000;
    wait;
  end process;

end;