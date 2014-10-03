LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

ENTITY tflop IS
  PORT (
    CLK   : IN  STD_LOGIC;
    Reset : IN  STD_LOGIC;
    T     : IN  STD_LOGIC;
    Q     : OUT STD_LOGIC
  );
END tflop;
ARCHITECTURE rtl OF tflop IS
  SIGNAL Next_Q: STD_LOGIC;
BEGIN
  PROCESS (CLK)
  BEGIN
    IF (RISING_EDGE(CLK)) THEN
      IF Reset = '1' THEN 
      Next_Q <= '0';
    ELSE
      IF T = '0' THEN
        Next_Q <= Next_Q;
      ELSIF T = '1' THEN
        Next_Q <= NOT(Next_Q);
      END IF;
    END IF;
    END IF;
  END PROCESS;
  Q <= Next_Q;
END rtl;