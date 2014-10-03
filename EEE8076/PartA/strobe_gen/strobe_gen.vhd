LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY strobe_gen IS
  GENERIC (
    MAX_COUNT : NATURAL := 9
  );
  PORT (
    CLK    : IN  STD_LOGIC;
    Reset  : IN  STD_LOGIC;
    Strobe : OUT STD_LOGIC
  );
END ENTITY;
ARCHITECTURE rtl OF strobe_gen IS
  SIGNAL cnt: INTEGER;
BEGIN
  PROCESS (CLK)
  BEGIN
    IF (RISING_EDGE(CLK)) THEN
      IF (Reset = '1') THEN   -- Reset counter and no output on reset
        Strobe <= '0';
        cnt    <= MAX_COUNT;
      ELSIF (cnt = 0) THEN    -- If countdown ends - send out a strobe pulse
        Strobe <= '1';
        cnt    <= MAX_COUNT;
      ELSE
        cnt    <= cnt - 1;    -- otherwise, just count down...
        Strobe <= '0';
      END IF;
    END IF;
  END PROCESS;
END rtl;