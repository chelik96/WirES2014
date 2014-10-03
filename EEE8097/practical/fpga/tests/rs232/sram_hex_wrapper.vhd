library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_hex_wrapper is

	port 
	(
		CLK  : in    std_logic;                     -- 50MHz Main Clock
		nRES : in    std_logic;                     -- Reset (Active Low)
		STBR : in    std_logic;                     -- strobe that uart sends when it receives a byte
		STBT : out   std_logic;                     -- strobe to uart to say we want to transmit a byte
		nRDY : in    std_logic;                     -- signals on high that the uart is sending data (not ready for more)
		Dmem : in    std_logic_vector (15 downto 0);-- Data Bus to SRAM memory
		Dout : out   std_logic_vector (7 downto 0); -- either upper or lower byte of data
		Amem : out   std_logic_vector (17 downto 0);-- Address Bus to SRAM memory
		Ain  : in    std_logic_vector (7 downto 0); -- either upper or lower byte of address
		nWE  : out   std_logic;                     -- Write Enable Active Low
		nOE  : out   std_logic;                     -- Output Enable Active Low
		nUB  : out   std_logic;                     -- Upper Byte Active Low
		nLB  : out   std_logic                      -- Lower Byte Active Low
	);

end entity;

architecture rtl of sram_hex_wrapper is
	-- 4 hex chars per 16-bit address to receive or data to send
	-- upper '11' for highest nibble or lower '00' for lowest nibble
	signal Tmode:  unsigned (1 downto 0);
	signal prevT:  unsigned(1 downto 0);
   signal Rmode:	unsigned (1 downto 0);
   -- counter used to wait for a transmission to complete before trying to send another
	signal txwait: unsigned (13 downto 0); -- wait for 10 bits * 443 clocks = 4430 clocks to wait
begin

	nWE   <= '1'; -- just leave inactive (high)
	nOE   <= '0'; -- just leave active (low)
	nUB   <= '0'; -- keep  upper byte...
	nLB   <= '0'; -- and lower byte active

	process (CLK, nRES)
	begin
		-- *** Reset *** 
		if nRES='0' then
			Rmode <= "11"; -- start receiving the upper nibble first
			Tmode <= "11"; -- start transmitted the upper nibble first

			Amem(17 downto 16) <= "00"; -- leave 2 MSB unchanged
			Amem(15 downto 0)  <= (others => '0'); -- reset memory address
		elsif rising_edge(CLK) then
			-- prevent inferrance of latches for unchanged 2 MSB in address
			Amem(17 downto 16) <= "00"; -- leave 2 MSB unchanged
			-- first check if strobe received - need to store received data
			if (STBR = '1') then
				if (Rmode = "11") then
					-- ensure character is a valid hex character and convert it
					-- first check numbers (ascii upper 4 bits will be '0011')
					if ((Ain(7 downto 4) = "0011") and (Ain(3 downto 0) < "1010")) then
						-- store nibble to address bus
						Amem(15 downto 12) <= Ain(3 downto 0);
						Rmode <= "10";
					-- now check for letters a-f or A-F
					elsif ((Ain(7 downto 4) = "0110") or (Ain(7 downto 4) = "0100")) and
							 (Ain(3 downto 0) < "0111") then
						-- store nibble to address bus
						Amem(15 downto 12) <= std_logic_vector(unsigned(Ain(3 downto 0)) + to_unsigned(9,4));
						Rmode <= "10";
					end if;
				elsif Rmode = "10" then
					-- ensure character is a valid hex character and convert it
					-- first check numbers (ascii upper 4 bits will be '0011')
					if ((Ain(7 downto 4) = "0011") and (Ain(3 downto 0) < "1010")) then
						-- store second nibble to address bus
						Amem(11 downto 8) <= Ain(3 downto 0);
						Rmode <= "01";
					-- now check for letters a-f or A-F
					elsif ((Ain(7 downto 4) = "0110") or (Ain(7 downto 4) = "0100")) and
							 (Ain(3 downto 0) < "0111") then
						-- store second nibble to address bus
						Amem(11 downto 8) <= std_logic_vector(unsigned(Ain(3 downto 0)) + to_unsigned(9,4));
						Rmode <= "01";
					end if;
				elsif Rmode = "01" then
					-- ensure character is a valid hex character and convert it
					-- first check numbers (ascii upper 4 bits will be '0011')
					if ((Ain(7 downto 4) = "0011") and (Ain(3 downto 0) < "1010")) then
						-- store third nibble to address bus
						Amem(7 downto 4) <= Ain(3 downto 0);
						Rmode <= "00";
					-- now check for letters a-f or A-F
					elsif ((Ain(7 downto 4) = "0110") or (Ain(7 downto 4) = "0100")) and
							 (Ain(3 downto 0) < "0111") then
						-- store third nibble to address bus
						Amem(7 downto 4) <= std_logic_vector(unsigned(Ain(3 downto 0)) + to_unsigned(9,4));
						Rmode <= "00";
					end if;
				elsif Rmode = "00" then
					-- ensure character is a valid hex character and convert it
					-- first check numbers (ascii upper 4 bits will be '0011')
					if ((Ain(7 downto 4) = "0011") and (Ain(3 downto 0) < "1010")) then
						-- store l nibble to address bus
						Amem(3 downto 0) <= Ain(3 downto 0);
						Rmode <= "11";
						-- got both address bytes so will be transmitting data after delay
						txwait <= txwait + to_unsigned(3,14);
						-- ensure we send upper bit first
						Tmode <= "11";
					-- now check for letters a-f or A-F
					elsif ((Ain(7 downto 4) = "0110") or (Ain(7 downto 4) = "0100")) and
							 (Ain(3 downto 0) < "0111") then
						-- store lowest nibble to address bus
						Amem(3 downto 0) <= std_logic_vector(unsigned(Ain(3 downto 0)) + to_unsigned(9,4));
						Rmode <= "11";
						-- ensure we send upper bit first
						Tmode <= "11";
						-- got 4 address nibbles so now transmit after few clocks delay
						txwait <= txwait + to_unsigned(3,14);
					end if;
				end if;
			end if;
			-- check if we have something to send and uart ready to send it
			-- if we are waiting, then keep waiting...
			if (txwait >  to_unsigned(1,14)) then
				txwait <= txwait - to_unsigned(1,14);
			-- however w have waited enough clock ticks, ensure we're ready to send out memory contents
			elsif txwait = to_unsigned(1,14) then
				-- send strobe to send byte
				STBT <= '1';
				txwait <= to_unsigned(0,14);
				if Tmode = "11" then
					-- send upper nibble data
					-- if less than 10 will be a number to send, otherwise a letter
					if unsigned(Dmem(15 downto 12)) < to_unsigned(10,4) then
						Dout(7 downto 4) <= "0011";
						Dout(3 downto 0) <= Dmem(15 downto 12);
					else
						Dout(7 downto 4) <= "0100";
						Dout(3 downto 0) <= std_logic_vector(unsigned(Dmem(15 downto 12)) - to_unsigned(9,4));
					end if;
					Tmode <= "10";
				elsif Tmode = "10" then
					-- send second nibble data
					-- if less than 10 will be a number to send, otherwise a letter
					if unsigned(Dmem(11 downto 8)) < to_unsigned(10,4) then
						Dout(7 downto 4) <= "0011";
						Dout(3 downto 0) <= Dmem(11 downto 8);
					else
						Dout(7 downto 4) <= "0100";
						Dout(3 downto 0) <= std_logic_vector(unsigned(Dmem(11 downto 8)) - to_unsigned(9,4));
					end if;
					Tmode <= "01";
				elsif Tmode = "01" then
					-- send third nibble data
					-- if less than 10 will be a number to send, otherwise a letter
					if unsigned(Dmem(7 downto 4)) < to_unsigned(10,4) then
						Dout(7 downto 4) <= "0011";
						Dout(3 downto 0) <= Dmem(7 downto 4);
					else
						Dout(7 downto 4) <= "0100";
						Dout(3 downto 0) <= std_logic_vector(unsigned(Dmem(7 downto 4)) - to_unsigned(9,4));
					end if;
					Tmode <= "00";
				elsif Tmode = "00" then
					-- send lower nibble data
					-- if less than 10 will be a number to send, otherwise a letter
					if unsigned(Dmem(3 downto 0)) < to_unsigned(10,4) then
						Dout(7 downto 4) <= "0011";
						Dout(3 downto 0) <= Dmem(3 downto 0);
					else
						Dout(7 downto 4) <= "0100";
						Dout(3 downto 0) <= std_logic_vector(unsigned(Dmem(3 downto 0)) - to_unsigned(9,4));
					end if;
					Tmode <= "11";
				end if;
			elsif (Tmode /= "11") and (prevT /= "00") then 
			   -- if we have not yet sent the last character there are more to come
				-- reset strobe and wait for the sending of the first data before sending next
				STBT <= '0';
				txwait <= to_unsigned(6000,14);
			else 
			   -- last character of data sent, so go idle now until something received
				-- reset strobe
				STBT <= '0';
				Tmode <= "11";
			end if;
			prevT <= Tmode;
		end if;
	end process;
end;