library ieee;
use ieee.std_logic_1164.all;

entity uart_tb IS
end uart_tb;
 
architecture arch of uart_tb is 

  -- unit under test
  component uart
  port(
    clk    : in  std_logic;
    rst    : in  std_logic;
    send   : in  std_logic;
    input  : in  std_logic_vector(7 downto 0);
    output : out std_logic_vector(7 downto 0)
  );
  end component;

  -- inputs & outputs
  signal clk    : std_logic := '0';
  signal rst    : std_logic := '0';
  signal send   : std_logic := '0';
  signal input  : std_logic_vector(7 downto 0) := (others => '0');
  signal output : std_logic_vector(7 downto 0);

  -- clock period
  constant clk_period : time := 20 ns;
 
BEGIN

  uut: uart port map (clk, rst, send, input, output);

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
	 
    input <= "10101010";
    send  <= '1';
    wait for clk_period;
    send  <= '0';
    wait for clk_period * 5000;

    input <= "01010101";
    send  <= '1';
    wait for clk_period;
    send  <= '0';
    wait for clk_period * 5000;

    input <= "11001100";
    send  <= '1';
    wait for clk_period;
    send  <= '0';
    wait for clk_period * 5000;
		
    input <= "00001111";
    send  <= '1';
    wait for clk_period;
    send  <= '0';
    wait for clk_period * 5000;

    input <= "00000000";
    send  <= '1';
    wait for clk_period;
    send  <= '0';
    wait for clk_period * 5000;	
	
    input <= "11111111";
    send  <= '1';
    wait for clk_period * 5000;
    send  <= '0';
    wait;
  end process;

end;