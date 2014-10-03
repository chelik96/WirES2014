library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart1 is

	port 
	(
		CLK		: in	std_logic; -- 50MHz
		nRES		: in	std_logic;
		RXD		: in	std_logic; -- 115200 baud, 50M/115200=434
		TXD	   : out	std_logic;
		DR			: out	std_logic_vector (7 downto 0);
		DT			: in	std_logic_vector (7 downto 0);
		STBR		: out	std_logic;
		STBT		: in	std_logic;
		nRDY     : out std_logic -- signals high when transmitting (not ready for new data)
	);

end entity;

architecture rtl of uart1 is

	signal fcntR	:	unsigned (9 downto 0); -- mod 434, once 434*1.5=651
	signal fcntT	:	unsigned (8 downto 0); -- mod 434
	signal bcntR	:	unsigned (3 downto 0);
	signal bcntT	:	unsigned (3 downto 0);
	signal stb1		:	std_logic; -- image of STBR

begin

	process (CLK, nRES)
	begin
		if nRES='0' then
			fcntR<=(others=>'0');
			fcntT<=(others=>'0');
			bcntR<=(others=>'0');
			bcntT<=(others=>'0');
			stb1<='0';
		elsif (rising_edge(CLK)) then
		
-------------receiver------------	
			if (bcntR=0 and fcntR=0) then --wait for start bit
				if RXD='0' then --start bit arrived
					fcntR<=to_unsigned(650,10); --longer time to hit the middle of the first data bit
					bcntR<=to_unsigned(8,4);
				end if;
			elsif (bcntR<9 and bcntR>0 and fcntR=0) then --data bits, LSB first
				DR(8-to_integer(bcntR))<=RXD;
				fcntR<=to_unsigned(433,10);
				bcntR<=bcntR-1;
				if bcntR=1 then --strobe triggered with the last bit
					stb1<='1';
				end if;
			else --not if fcntR=0
				fcntR<=fcntR-1;
			end if;
			
			if stb1='1' then --reset the strobe with the next clock
				stb1<='0';
			end if;
--------------transmitter--------
			if STBT='1' then 
				fcntT <= to_unsigned(433,9);
				bcntT <= to_unsigned(8,4);
				TXD   <= '0'; --start bit
				nRDY  <= '1'; -- sending data - so prevent new data arriving
			elsif fcntT=0 and bcntT>0 then --data bits
				TXD   <= DT(8-to_integer(bcntT));
				bcntT <= bcntT-1;
				fcntT <= to_unsigned(433,9);
			elsif fcntT=0 and bcntT=0 then --stop bit and until next STBT='1'
				TXD   <= '1';
				nRDY  <= '0'; -- finished sending - can send something else now.
			else --not if fcntT=0
				fcntT<=fcntT-1;
			end if;

--------------end----------------			
		end if;
	end process;

	STBR<=stb1;

end rtl;
