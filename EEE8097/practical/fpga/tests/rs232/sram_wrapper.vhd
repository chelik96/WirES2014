library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_wrapper is

	port 
	(
		CLK  : in    std_logic;                     -- 50MHz Main Clock
		nRES : in    std_logic;                     -- Reset (Active Low)
		STBR : in    std_logic;                     -- strobe that uart sends when it receives a byte
		STBT : out   std_logic;                     -- strobe to uart to say we want to transmit a byte
		Dmem : in    std_logic_vector (15 downto 0);-- Data Bus to SRAM memory
		Dout : out   std_logic_vector (7 downto 0); -- either upper or lower byte of data
		Amem : out   std_logic_vector (17 downto 0);-- Address Bus to SRAM memory
		Ain  : in    std_logic_vector (7 downto 0); -- either upper or lower byte of address
		nWE  : out   std_logic;                     -- Write Enable Active Low
		nOE  : out   std_logic;                     -- Output Enable Active Low
		nUB  : out   std_logic;                     -- Upper Byte Active Low
		nLB  : out   std_logic;                     -- Lower Byte Active Low
		nRDY : in    std_logic                      -- set high while uart busy transmitting
	);

end entity;

architecture rtl of sram_wrapper is
   signal txwait: unsigned (13 downto 0); -- wait for 10 bits * 443 clocks = 4430 clocks to wait
	signal Tmode :	std_logic; -- upper '1' or lower '0' byte toggle
   signal Rmode :	std_logic; -- upper '1' or lower '0' byte toggle
	
begin
	-- ensure constant signals are maintained
	nWE   <= '1'; -- just leave inactive (high)
	nOE   <= '0'; -- just leave active (low)
	nUB   <= '0'; -- start with upper byte...
	nLB   <= '0'; -- and with lower byte

	process (CLK, nRES)
	begin
		-- *** Reset *** 
		if nRES='0' then
			Rmode <= '1'; -- start receiving the upper byte first
			Tmode <= '1'; -- start transmitted the upper byte first

			Amem(17 downto 16) <= "00"; -- leave 2 MSB unchanged
			Amem(15 downto 0)  <= (others => '0'); -- reset memory address
		elsif rising_edge(CLK) then
			-- first check if strobe received - need to store received data
			if STBR = '1' then
				if Rmode = '1' then
					-- store upper byte to address bus
					Amem(15 downto 8) <= Ain;
					Rmode <= '0';
				else
					Amem(7 downto 0)  <= Ain;
					Rmode <= '1';
					-- got both address bytes so *can* transmit after few clocks delay
					txwait <= txwait + to_unsigned(3,14);
					-- ensure we send upper bit first
					Tmode <= '1';
				end if;
			end if;
			-- check if we have something waiting to send (txwait will be non-zero)
			-- if it is greater than one however, keep waiting until transmit finished
			if txwait > to_unsigned(1,14) then
				txwait <= txwait - to_unsigned(1,14);
			-- if we have waited the requisite clock ticks, ready to send out memory contents
		   elsif txwait = to_unsigned(1,14) then
				txwait <= to_unsigned(0,14);
				-- send strobe to send byte
				STBT <= '1';
				if Tmode = '1' then
					-- send upper byte
					Dout <= Dmem(15 downto 8);
					Tmode <= '0';
				else
					-- send lower byte
					Dout <= Dmem(7 downto 0);
					Tmode <= '1';
				end if;
			elsif Tmode = '0' then
				-- reset strobe and wait for the sending of the first data before sending next
				STBT <= '0';
				txwait <= to_unsigned(6000,14);
			else
				-- just reset strobe.
				STBT <= '0';
			end if;
		end if;
	end process;
end;