LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY slow IS
  PORT (
    CLK   : IN  STD_LOGIC;
    Reset : IN  STD_LOGIC;
    Q     : OUT STD_LOGIC
  );
END ENTITY;
ARCHITECTURE Structure OF slow IS
  COMPONENT tflop
    PORT (
      CLK   : IN  STD_LOGIC;
      Reset : IN  STD_LOGIC;
      T     : IN  STD_LOGIC;
      Q     : OUT STD_LOGIC
    );
  END COMPONENT;
  COMPONENT strobe_gen
    PORT (
      CLK    : IN  STD_LOGIC;
      Reset  : IN  STD_LOGIC;
      Strobe : OUT STD_LOGIC
    );
  END COMPONENT;
  SIGNAL strobe_to_T : STD_LOGIC;
BEGIN
  tflop1 : tflop      PORT MAP (CLK, Reset, strobe_to_T, Q);
  strob1 : strobe_gen PORT MAP (CLK, Reset, strobe_to_T);
END Structure;