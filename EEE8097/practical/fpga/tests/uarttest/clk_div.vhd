library ieee;
use ieee.std_logic_1164.all;

-- complete UART component, built from a Transmitter (tx) and Receiver (rx).
-- Currently set to function as a 'loop back' of received data only.
entity clk_div is
  port(
    clk    : in  std_logic;
    rst    : in  std_logic;
    clk_tx : out std_logic;
    clk_rx : out std_logic);
end clk_div;

architecture arch of clk_div is
	-- receiver needs to be 8 times faster than baud of 28800bps, ie. 230.4KHz
	-- master clock is 50MHz, so 50Mhz/230.4Khz = approx 217
  constant div_rx : integer   := 217;
  -- transmitter needs to be 8 times slower than the revceiver
  constant div_tx : integer   := 8;
  signal cnt_rx   : integer   := 0;
  signal cnt_tx   : integer   := 0;
  signal clk_rx_t : std_logic := '0';
  signal clk_rx_o : std_logic := '0';
  signal clk_tx_t : std_logic := '0';
begin

  process(clk, rst)
  begin
    if (rst = '1') then
      cnt_rx <= 0;
      cnt_tx <= 0;
    else
      -- when rising edge of clock, count till div_rx then reset the count
      if (rising_edge(clk)) then
        if (cnt_rx = div_rx - 1) then 
          cnt_rx <= 0;
          clk_rx_o <= clk_rx_t;
          if (clk_rx_t = '1') then
            clk_rx_t <= '0';
          elsif (clk_rx_t = '0') then
            clk_rx_t <= '1';
          end if;
        else
          cnt_rx <= cnt_rx + 1;
        end if;
      end if;
      -- when rising edge of clk_rx, count till div_tx
      -- if count is 8 then reset the count
      if (clk_rx_t = '1' and clk_rx_o = '0') then
        if (cnt_tx = div_tx - 1) then 
          cnt_tx <= 0;
          if (clk_tx_t = '1') then
            clk_tx_t <= '0';
          elsif (clk_tx_t = '0') then
            clk_tx_t <= '1';
          end if;
        else
          cnt_tx <= cnt_tx + 1;
        end if;
      end if;
    end if;
  end process;	
  clk_rx   <= clk_rx_t;
  clk_tx   <= clk_tx_t;
end arch;