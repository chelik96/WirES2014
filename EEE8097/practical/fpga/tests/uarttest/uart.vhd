library ieee;
use ieee.std_logic_1164.all;

-- complete UART component, built from a Transmitter (tx) and Receiver (rx).
-- Currently set to function as a 'loop back' of received data only.
entity uart is
  port(
    clk    : in  std_logic;
    rst    : in  std_logic;
    send   : in  std_logic;
    input  : in  std_logic_vector(7 downto 0) := "00000000";
    output : out std_logic_vector(7 downto 0) := "00000000");
end uart;

architecture arch of uart is

  component tx is
  port(
    clk    : in  std_logic;
	 rst    : in  std_logic;
	 input  : in  std_logic_vector(7 downto 0);
    output : out std_logic;
    send   : in  std_logic;
    sent   : out std_logic
  );
  end component;

  component rx is
  port(
    clk    : in  std_logic;
	 rst    : in  std_logic := '0';
	 input  : in  std_logic;
    output : out std_logic_vector(7 downto 0)
  );
  end component;

  signal output_t       : std_logic := '1';
  signal sent           : std_logic := '0';
  signal clk_tx, clk_rx : std_logic := '0';
  signal cnt1, cnt2     : integer   := 0;

begin

  tx1: tx
  port map( 
    clk  => clk_tx,
	 rst  => rst,
	 input => input,
    output => output_t, -- stored transmitter output temporarily
    send => send,
    sent => sent
  );

  rx1 : rx
  port map(
    input => output_t, -- take input from generated output
    clk => clk_rx,
	 rst => rst,
    output => output
  );

  process(clk, clk_rx)
  begin 
    -- when rising edge of clock, count till 54 then reset the count
	 -- receiver needs to be 8 times faster than baud of 28800bps = 230.4KHz
	 -- master clock is 50MHz, so 50Mhz/230.4Khz = approx 217
    if (rising_edge(clk)) then
      if (cnt1 = 217) then 
        cnt1 <= 0;
        if (clk_rx = '1') then
          clk_rx <= '0';
        elsif (clk_rx = '0') then
          clk_rx <= '1';
        end if;
      else
        cnt1 <= cnt1 + 1;
      end if;
    end if;
    -- when rising edge of clk_rx, count till 8
    -- if count is 8 then reset the count
    if (rising_edge(clk_rx)) then
      if (cnt2 = 7) then 
        cnt2 <= 0;
        if (clk_tx = '1') then
          clk_tx <= '0';
        elsif (clk_tx = '0') then
          clk_tx <= '1';
        end if;
      else
        cnt2 <= cnt2 + 1;
      end if;
    end if;
  end process;	

end arch;