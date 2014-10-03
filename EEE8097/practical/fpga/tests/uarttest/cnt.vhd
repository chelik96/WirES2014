library ieee;
use ieee.std_logic_1164.all;

-- Counter, used in both receiver (rx) and transmitter (tx) to count correct
-- number of data bits (8) before a stop code should be sent/received.
entity cnt is
  generic ( ovf_cnt : integer := 7);
  port(
    rst : in  std_logic; -- input to reset the count
    clk : in  std_logic;  -- clock of counter
    ovf : out std_logic := '0'); -- overflow bit to indicate the overflow
end cnt;

architecture arch of cnt is
  signal c : integer := 0; -- count of pulses
begin 
	 
  clk_proc: process(clk)
  begin
    -- on clock, increment the count till it overflows or a reset comes
    if rising_edge(clk) then
	   if (rst = '1') then
        c   <= 0;
      -- if count equals overflow, then set overflow high
      elsif (c = ovf_cnt) then
        ovf <= '1';
        c   <= 0;
      -- else set overflow low
      else 
        ovf <= '0';
        c   <= c + 1;
      end if;
    end if;
  end process;

end arch;