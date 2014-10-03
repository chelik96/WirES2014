LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY strobe_gen_testbench IS
END strobe_gen_testbench;
ARCHITECTURE strobe_gen_arch OF strobe_gen_testbench IS
  SIGNAL CLK, Reset, Strobe : STD_LOGIC;
  COMPONENT strobe_gen
    PORT (
      CLK    : IN  STD_LOGIC;
      Reset  : IN  STD_LOGIC;
      Strobe : OUT STD_LOGIC
    );
  END COMPONENT;
BEGIN
  testcomp : strobe_gen PORT MAP (CLK, Reset, Strobe);
  testinputs : PROCESS
  BEGIN
    Reset <= '1';      -- No Strobing
    WAIT FOR 200 ns;
    Reset <= '0';      -- Should see strobe start strobing
    WAIT FOR 1000 ns;
    Reset <= '1';      -- No Strobing for a longish time
    WAIT FOR 1000 ns;
    Reset <= '0';      -- Should see strobe start strobing again
    WAIT;
  END PROCESS testinputs;
-- Stop simulation after fixed number of cycles
-- clock period = 20 ns (50Mz frequency req. period of 1/50,0000,0000s = 20ns)
  clock : PROCESS
  BEGIN
    FOR clksteps IN 0 TO 100 LOOP
      CLK <= '0';
      WAIT FOR 10 ns;
      CLK <= NOT CLK;
      WAIT FOR 10 ns;
    END LOOP; 
    WAIT;
  END PROCESS clock;
END strobe_gen_arch;