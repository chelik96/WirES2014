library ieee;
use ieee.std_logic_1164.all;
 
entity sipo_tb is
end sipo_tb;
 
architecture arch of sipo_tb is 

  -- unit under test
  component sipo
  port(
    clk  : in  std_logic;
    rdy  : in  std_logic;
    send : in  std_logic;
	 sin  : in  std_logic;
    pout : out std_logic_vector(7 downto 0)
  );
  end component;

  -- inputs & outputs
  signal clk  : std_logic := '0';
  signal rdy  : std_logic := '0';
  signal send : std_logic := '0';
  signal sin  : std_logic := '0';
  signal pout : std_logic_vector(7 downto 0);

  -- clock period
  constant clk_period : time := 10 ns;

begin

  uut: sipo port map (clk, rdy, send, sin, pout);

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
    -- hold reset state for a while.
    wait for clk_period * 20;	

	 -- Send '10111010' serially
    rdy <= '1';
	 wait for clk_period;
    sin <= '0';
	 rdy <= '0';
	 wait for clk_period;
    sin <= '1';
    wait for clk_period;
    sin <= '0';
    wait for clk_period;
    sin <= '1';
    wait for clk_period;
    sin <= '1';
    wait for clk_period;
    sin <= '1';
    wait for clk_period;
    sin <= '0';
    wait for clk_period;
    sin <= '1';
    wait for clk_period;
	 
    send <= '1';
    wait for clk_period;
    send <= '0';
    wait for clk_period;
	 
	 -- Send '00110011' serially
    rdy <= '1';
	 wait for clk_period;
    sin <= '1';
	 rdy <= '0';
    wait for clk_period;
    sin <= '1';
    wait for clk_period;
    sin <= '0';
    wait for clk_period;
    sin <= '0';
    wait for clk_period;
    sin <= '1';
    wait for clk_period;
    sin <= '1';
    wait for clk_period;
    sin <= '0';
    wait for clk_period;
    sin <= '0';
    wait for clk_period;
	 
    send <= '1';
    wait for clk_period;
    send <= '0';
    wait for clk_period;
	
	 -- Send '10101010' serially
    rdy <= '1';
    wait for clk_period;
    sin <= '0';
	 rdy <= '0';
    wait for clk_period;
    sin <= '1';
    wait for clk_period;
    sin <= '0';
    wait for clk_period;
    sin <= '1';
    wait for clk_period;
    sin <= '0';
    wait for clk_period;
    sin <= '1';
    wait for clk_period;
    sin <= '0';
    wait for clk_period;
    sin <= '1';
    wait for clk_period;
	 
    send <= '1';
    wait for clk_period;
    send <= '0';
    wait;	

  end process;

end;