library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BIST is
	port (
		CLOCK : in  STD_LOGIC;
		OUTPUT: out out STD_LOGIC_VECTOR (3 downto 0)
	);
	 
end BIST;

architecture structural of BIST is

component PBRS_generator is
    port (
		PATTERN : out  STD_LOGIC_VECTOR (9 downto 0);
      CLOCK   : in   STD_LOGIC);
end component;

component ALU is
	port (
		CLOCK : in  STD_LOGIC;
		F: in  STD_LOGIC_VECTOR (1 downto 0);
		A: in  STD_LOGIC_VECTOR (3 downto 0);
		B: in  STD_LOGIC_VECTOR (3 downto 0);
		O: out STD_LOGIC_VECTOR (3 downto 0)
	);
end component;

component SIGNATURE is
	port (
		CLOCK  : in  STD_LOGIC;
      INPUT  : in  STD_LOGIC_VECTOR (3 downto 0);
      OUTPUT : out STD_LOGIC_VECTOR (3 downto 0));
end component;

signal PATTERN STD_LOGIC_VECTOR (9 downto 0);
signal RESULT STD_LOGIC_VECTOR (3 downto 0);

begin

gen:PBRS_generator port map (
	CLOCK => CLOCK,
	PATTERN => PATTERN
);
dut:ALU port map (
	CLOCK => CLOCK,
	F => PATTERN(9 downto 8),
	A => PATTERN(7 downto 4),
	B => PATTERN(3 downto 0),
	O => RESULT
);
sig:SIGNATURE port map (
	CLOCK => CLOCK,
	INPUT => RESULT,
	OUTPUT => OUTPUT
);

end structural;