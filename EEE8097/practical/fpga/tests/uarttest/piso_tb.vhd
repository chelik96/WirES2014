library ieee;
use ieee.std_logic_1164.all;

entity piso_tb is
end piso_tb;
 
architecture arch of piso_tb is

  -- unit under test
  component piso
  port(
    clk  : in  std_logic;
    we   : in  std_logic;
    pin  : in  std_logic_vector(7 downto 0);
    sout : out std_logic
  );
  end component;
    
  -- inputs & outputs
  signal clk  : std_logic := '0';
  signal we   : std_logic := '0';
  signal pin  : std_logic_vector(7 downto 0) := (others => '0');
  signal sout : std_logic;

  -- clock period
  constant clk_period : time := 10 ns;

begin

  uut: piso port map (clk,we,pin,sout);

  -- clock process
  clk_proc: process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;
 
  -- stimulus process
  stim_proc: process
  begin		
    -- hold reset for a while at the start.
    wait for clk_period * 20;	
  
    -- load a test sequence
    we <= '1';
    pin <= "01010101";
    wait for clk_period;

    -- serially output the sequence of 8 bits
    we <= '0';
    wait for clk_period * 9;
		
    -- load a new byte
    we <= '1';
    pin <= "11000011";
    wait for clk_period;
		
    -- serially output the sequence of 8 bits
    we <= '0';
    wait for clk_period * 9;
	 
    -- load penultimate sequence
    we <= '1';
	 pin <= "01001010";
    wait for clk_period;
		
    -- serially output the sequence of 8 bits
    we <= '0';
    wait for clk_period * 9;

    -- load last sequence
    we <= '1';
	 pin <= "01111111";
    wait for clk_period;
		
    -- serially output the sequence of 8 bits
    we <= '0';
    wait for clk_period * 9;
  end process;

end;