library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SIGNATURE is
	Port (
		CLOCK  : in  STD_LOGIC;
      INPUT  : in  STD_LOGIC_VECTOR (3 downto 0);
      OUTPUT : out STD_LOGIC_VECTOR (3 downto 0));
end SIGNATURE;

architecture Behavioral of SIGNATURE is
  signal lsfr: STD_LOGIC_VECTOR(3 downto 0) := b"1000";
begin
	main: process (CLOCK)
	begin
		-- Update Output
		OUTPUT <= lsfr;
		-- Process Loopback
		lsfr(3) <= INPUT(3) xor (lsfr(1) xor lsfr(0));
		-- Shift registers
		lsfr(2 downto 0) <= INPUT(2 downto 0) xor lsfr(3 downto 1);
	end process main;
end Behavioral;

