library ieee;
use ieee.std_logic_1164.all;

entity strobe_gen_tb is
end strobe_gen_tb;

architecture tb of strobe_gen_tb is
  signal CLK, RST, STR : std_logic;
  component strobe_gen
    port (
      CLK : in  std_logic;
      RST : in  std_logic;
      STR : out std_logic
    );
  end component;
begin
  duu : strobe_gen port map (CLK, RST, STR);

  clk_proc: process
  begin
    for I in 0 to 100 loop
      CLK <= '0';
      wait for 10 ns;
      CLK <= not(CLK);
      wait for 10 ns;
    end loop;
    wait;
  end process clk_proc;

  test_proc: process
  begin
    RST <= '1'; -- No strobing
    wait for 200 ns;
    RST <= '0'; -- Should see strobe start strobing
    wait for 1000 ns;
    RST <= '1'; -- No strobing for a relatively long time
    wait for 1000 ns;
    RST <= '0'; -- Should see strobe start strobing again
    wait;
  end process test_proc;

end tb;
