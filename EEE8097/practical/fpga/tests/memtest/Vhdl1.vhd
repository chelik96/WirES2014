LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

-- assumes master clock rate is 50Mhz (DE-1)
ENTITY rate_controller IS
  PORT (
     mst_clk: IN  std_logic;
     rst    : IN  std_logic;
     clkout : OUT std_logic;
   );
 END rate_controller
 
 ARCHITECTURE rtl OF rate_controller IS
  CONSTANT clk_div: INTEGER := 5208;
  SIGNAL count  : INTEGER := 0;
BEGIN
  div: PROCESS (rst, clk)
  BEGIN
    IF rst = '0' THEN
      clk_div <= 0;
      count   <= 0;
    ELSIF rising_edge(clk) THEN
      
