LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY slow_testbench IS
END slow_testbench;
ARCHITECTURE slow_arch OF slow_testbench IS
  SIGNAL CLK, Reset, Q : STD_LOGIC;
  COMPONENT slow
    PORT (
      CLK   : IN  STD_LOGIC;
      Reset : IN  STD_LOGIC;
      Q     : OUT STD_LOGIC
    );
  END COMPONENT;
BEGIN
  testcomp : slow PORT MAP (CLK, Reset, Q);

-- Basic signal Testing (need to expand for edge-cases)
  testinputs : PROCESS
  BEGIN
    Reset <= '1';      -- Q goes low
    WAIT FOR 200 ns;
    Reset <= '0';      -- Should now see periodic toggle of Q from high to low every 10 clock pulses
    WAIT FOR 1000 ns;
    Reset <= '1';      -- Should not see any toggling - Q should be low
    WAIT FOR 1000 ns;
    Reset <= '0';      -- Should see toggling again...
	 WAIT FOR 10000 ns;
	 Reset <= '1';      -- No More toggling. except we change back to reset 0 almost straight away
	 WAIT FOR 40ns;
	 Reset <= '0';      -- Change in Reset shouldn't effect behaviour - not high long enough
    WAIT;
  END PROCESS testinputs;

-- stop simulation after fixed number of cycles
-- clock period = 20 ns (50Mz frequency req. period of 1/50,0000,0000s = 20ns)
  clock : PROCESS
  BEGIN
    FOR clksteps IN 0 TO 1000 LOOP
      CLK <= '0';
      WAIT FOR 10 ns;
      CLK <= NOT CLK;
      WAIT FOR 10 ns;
    END LOOP; 
    WAIT;
  END PROCESS clock;
END slow_arch;