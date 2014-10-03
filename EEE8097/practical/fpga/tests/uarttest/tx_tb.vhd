library ieee;
use ieee.std_logic_1164.all;
 
entity tx_tb is
end tx_tb;

architecture arch of tx_tb is 

  -- unit under test
  component tx
  port(
    clk    : in  std_logic;
	 rst    : in  std_logic;
	 input  : in  std_logic_vector(7 downto 0);
    output : out std_logic;
    send   : in  std_logic;
    sent   : out std_logic
  );
  end component;
    
  -- inputs & outputs
  signal clk    : std_logic := '0';
  signal rst    : std_logic := '1';
  signal input  : std_logic_vector(7 downto 0) := (others => '0');
  signal output : std_logic;
  signal send   : std_logic := '0';
  signal sent   : std_logic := '0';

  -- clock period
  constant clk_period : time := 10 ns;
 
begin

  uut: tx port map (clk, rst, input, output, send, sent);

  -- clock process
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;
 
  -- stimulus process
  stim_proc: process
  begin		
    -- hold reset state for a while.
	 rst <= '1';
    wait for clk_period * 20;	
	 rst <= '0';
	 
    input <= "10101010";
    send  <= '1';
    wait for clk_period;
    send  <= '0';

    wait for clk_period * 20;
    input <= "00111100";
    send  <= '1';
    wait for clk_period;
    send  <='0';

    wait for clk_period * 20;
    input <= "10000001";
    send  <= '1';
    wait for clk_period;
    send  <= '0';
    wait;
  end process;
  
end;