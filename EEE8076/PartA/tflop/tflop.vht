LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY tflop_testbench IS
END tflop_testbench;
ARCHITECTURE tflop_arch OF tflop_testbench IS
  SIGNAL CLK, Q, Reset, T : STD_LOGIC;
  COMPONENT tflop
    PORT (
      CLK   : IN  STD_LOGIC;
      Reset : IN  STD_LOGIC;
      T     : IN  STD_LOGIC;
      Q     : OUT STD_LOGIC
    );
  END COMPONENT;
BEGIN
  testcomp : tflop PORT MAP (CLK, Reset, T, Q);

-- Basic signal Testing (need to expand for edge-cases)
  testinputs : PROCESS
  BEGIN
    Reset <= '1';    -- Q should go Low
    WAIT FOR 200 ns;
    Reset <= '0';    -- Q Should stay Low
    WAIT FOR 200 ns;
    T <= '1';        -- Q Should go High
    WAIT FOR 200 ns;
    T <= '0';        -- Q Should stay High
    WAIT FOR 200 ns;
    T <= '1';        -- Q Should go Low
    WAIT FOR 200 ns;
    T <= '0';        -- Q Should stay Low
    WAIT FOR 200 ns;    
    T <= '1';        -- Q Should go High
    WAIT FOR 200 ns;
    T <= '0';        -- Q Should stay High
    WAIT FOR 200 ns;
    Reset <= '1';    -- Q Should go Low
    WAIT;
  END PROCESS testinputs;

-- stop simulation after fixed number of cycles
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
END tflop_arch;