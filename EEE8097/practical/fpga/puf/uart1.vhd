library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart1 is

	port 
	(
		CLK		: in	std_logic; -- 50MHz
		RST		: in	std_logic;
		RXD		: in	std_logic; -- 115200 baud, 50M/115200=434
		TXD	   : out	std_logic;
		DRX			: out	std_logic_vector (7 downto 0);
		DTX			: in	std_logic_vector (7 downto 0);
		STR		: out	std_logic;
		STT		: in	std_logic
);

end entity;

architecture rtl of uart1 is

	signal fcnTRX	:	unsigned (9 downto 0); -- mod 434, once 434*1.5=651
	signal fcntT	:	unsigned (8 downto 0); -- mod 434
	signal bcnTRX	:	unsigned (3 downto 0);
	signal bcntT	:	unsigned (3 downto 0);
	signal stb1		:	std_logic; -- image of STR

begin

	process (CLK, RST)
	begin
		if RST='0' then
			fcnTRX<=(others=>'0');
			fcntT<=(others=>'0');
			bcnTRX<=(others=>'0');
			bcntT<=(others=>'0');
			stb1<='0';
		elsif (rising_edge(CLK)) then
		
-------------receiver------------	
			if (bcnTRX=0 and fcnTRX=0) then --wait for start bit
				if RXD='0' then --start bit arrived
					fcnTRX<=to_unsigned(650,10); --longer time to hit the middle of the first data bit
					bcnTRX<=to_unsigned(8,4);
				end if;
			elsif (bcnTRX<9 and bcnTRX>0 and fcnTRX=0) then --data bits, LSB first
				DRX(8-to_integer(bcnTRX))<=RXD;
				fcnTRX<=to_unsigned(433,10);
				bcnTRX<=bcnTRX-1;
				if bcnTRX=1 then --sTRXobe TRXiggered with the last bit
					stb1<='1';
				end if;
			else --not if fcnTRX=0
				fcnTRX<=fcnTRX-1;
			end if;
			
			if stb1='1' then --reset the sTRXobe with the next clock
				stb1<='0';
			end if;
--------------TRXansmitter--------
			if STT='1' then 
				fcntT <= to_unsigned(433,9);
				bcntT <= to_unsigned(8,4);
				TXD   <= '0'; --start bit
			elsif fcntT=0 and bcntT>0 then --data bits
				TXD   <= DTX(8-to_integer(bcntT));
				bcntT <= bcntT-1;
				fcntT <= to_unsigned(433,9);
			elsif fcntT=0 and bcntT=0 then --stop bit and until next STT='1'
				TXD   <= '1';
			else --not if fcntT=0
				fcntT<=fcntT-1;
			end if;

--------------end----------------			
		end if;
	end process;

	STR<=stb1;

end rtl;
