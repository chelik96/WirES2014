Library IEEE;
use IEEE.std_logic_1164.all;

use work.SBA_config.all;
use work.SBA_package.all;

entity TX_Adapter is
generic (baud:positive:=57600);
port (
      -- SBA Bus Interface
      CLK_I : in std_logic;
      RST_I : in std_logic;
      WE_I  : in std_logic;
      STB_I : in std_logic;
      DAT_I : in DATA_type;
      DAT_O : out DATA_type;
      -- UART Interface;
      TX     :out std_logic
   );
end TX_Adapter;
--------------------------------------------------

architecture arch1 of TX_Adapter is

signal CLKi  : std_logic;
signal TXRDYi: std_logic;
signal WENi  : std_logic;
signal TxData: std_logic_vector(8 downto 0);
signal TxC   : integer range 0 to 9;

constant BaudDV : integer := integer(real(sysfrec)/real(2*baud))-1;

begin

SBAData: process (RST_I,WENi,CLK_I)
begin
  if rising_edge(CLK_I) then
    if WENi='1' then
      TxData <= DAT_I(7 downto 0) & '0';
    end if;
  end if;
end process SBAData;

TxProc:process (RST_I,WENi,CLKi)
begin
  if (RST_I='1') then
    TXRDYi <= '1';
    TxC<=9;
    TX <= '1';
  elsif (WENi='1') then
    TXRDYi <= '0';
    TxC<=0;
    TX <= '1';
  elsif rising_edge(CLKi) then
    if TxC<9 then
      TXRDYi <= '0';
      TX <= TxData(TxC);
      TxC<=TxC+1;
    else
      TX <= '1';
      TXRDYi <= '1';
    end if;
  end if;
end process TxProc;

BaudGen: process (RST_I,CLK_I)
Variable cnt: integer range 0 to BaudDV;
begin
  if RST_I='1' then
    CLKi <= '1';
    cnt:=0;
  elsif rising_edge(CLK_I) then
    if cnt=BaudDV then
      CLKi <= not CLKi;
      cnt := 0;
    else   
      cnt:=cnt+1;
    end if;
  end if;
end process BaudGen;

WENi <= (STB_I and WE_I and not RST_I);
DAT_O <= (14 => TXRDYi, others => '0');

end arch1;