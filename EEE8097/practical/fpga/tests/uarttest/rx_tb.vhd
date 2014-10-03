library ieee;
use ieee.std_logic_1164.all;

entity rx_tb is
end rx_tb;

architecture arch of rx_tb is

  -- unit under test
  component rx
  port(
    clk    : in  std_logic;
    rst    : in  std_logic;
	 input  : in  std_logic;
    output : out std_logic_vector(7 downto 0)
  );
  end component;

  -- inputs & outputs
  signal clk    : std_logic := '0';
  signal rst    : std_logic := '1';
  signal input  : std_logic := '0';
  signal output : std_logic_vector(7 downto 0);

  -- clock period
  constant clk_period : time := 1 ns;

begin

  uut: rx port map (clk, rst, input, output);

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
    -- hold for a while.
    input <= '1';
    wait for clk_period * 20;
	 
	 rst <= '0';
	 
	 -- try receiving the 8 bit value '01010101'
	 input <= '0'; -- start bit
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '1'; -- stop bit
    wait for clk_period * 64;
	 
	 -- try receiving the 8 bit value '11001100'
	 input <= '0'; -- start bit
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1'; -- stop bit
    wait for clk_period * 16;
	 
	 -- try receiving the 8 bit value '00001111'
	 input <= '0'; -- start bit
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1'; -- stop bit
    wait for clk_period * 16;
	 
	 -- try receiving the 8 bit value '1111111'
	 input <= '0'; -- start bit
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1';
    wait for clk_period * 16;
    input <= '1'; -- stop bit
    wait for clk_period * 16;
	 
	 -- try receiving the 8 bit value '00000000'
	 input <= '0'; -- start bit
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '0';
    wait for clk_period * 16;
    input <= '1'; -- stop bit
    wait; 

  end process;

end;