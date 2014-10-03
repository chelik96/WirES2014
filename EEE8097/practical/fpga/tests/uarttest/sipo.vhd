library ieee;
use ieee.std_logic_1164.all;

-- SIPO - Serial in, Parallel Out Shift Register. Component of Receiver (rx).
entity sipo is
  generic (bits:positive:=8);
  port (
    clk  : in  std_logic;                     -- Master Clock
    rdy  : in  std_logic;                     -- Indicates about to start receiveing
    send : in  std_logic;                     -- Indicates when to show output
    sin  : in  std_logic;                     -- Serial Input
    pout : out std_logic_vector(bits-1 downto 0)   -- Parallel Output
  );
end sipo;

architecture arch of sipo is
  signal sr  : std_logic_vector(bits-1 downto 0) := "00000000"; -- Shift Register to store input
  signal old : std_logic := '0'; -- track previous ready value to find rising edge
  signal c   : integer := 0; -- Counter
begin

  process(clk)
  begin
    if (rising_edge(clk)) then
	   -- when send high output contents of register
      if (send = '1') then
        pout <= sr;
      end if;
      -- reset count and shift register at the start of a input
      if (rdy = '0' and old='1') then
        c  <= 0;
        sr <= "00000000";
      -- count 8 bits in input
      elsif (c < bits) then
        sr(c) <= sin;
        c     <= c + 1;
      end if;
		old <= rdy;
    end if;
  end process;

end arch;