--------------------------------------------------------------------------------
-- PUF  - Core Physically Unclonable Function Implementation
--        For EEE8097 Masters Project
--
-- Links both the SRAM wrapper and UART modules together and
-- to the pins connected to the on-board hardware of the DE-1
--
-- Copyright (C) 2014 Michael Walker
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- This is the Top-Level Entity of the PUF system implemented in FPGA
-- all signals in port list of entity are linked to physical parts of DE-1
-- with necessary names for pins as specified in the user manual.
ENTITY PUF IS
	PORT
	(
		CLOCK_50  : IN  STD_LOGIC;                     --Master Clock (50MHz)
		KEY       : IN  STD_LOGIC_VECTOR(0 TO 0);      --KEY0 button for reset

		UART_RXD  : IN  STD_LOGIC;                     --RS-232 Receive wire
		UART_TXD  : OUT STD_LOGIC;                     --RS-232 Transmit wire
		
		SRAM_DQ   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); --16-bit SRAM Data bus
		SRAM_ADDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 0); --18-bit SRAM Address bus

		LEDG      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  --Green LEDs - RXD Byte
		LEDR      : OUT STD_LOGIC_VECTOR(0 TO 0);      --Red LED - not(reset)

		SRAM_WE_N : OUT STD_LOGIC;                     -- SRAM Write Enable
		SRAM_OE_N : OUT STD_LOGIC                      -- SRAM Output Enable
	);
END PUF;

ARCHITECTURE rtl OF PUF IS

-- UART communicates via RS-232 with rest of PUF system simulated in Matlab
-- It handles both converting the serial stream received over RS-232 into
-- parallel bytes to be passed to SRAM component and the return path back.
COMPONENT UART1
	PORT(
		CLK : IN STD_LOGIC;
		RST : IN STD_LOGIC;
		RXD : IN STD_LOGIC;
		TXD : OUT STD_LOGIC;
		DRX : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		DTX : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		STR : OUT STD_LOGIC;
		STT : IN STD_LOGIC
	);
END COMPONENT;

-- SRAM receives in a 16-bit address as 4 bytes of ASCII hexadecimal
-- characters and sets the address bus of the SRAM memory to that value.
-- It then retrieves the resulting 16-bit data from the SRAM memory and
-- transmits it back in same hexadecimal format.
COMPONENT SRAM
	PORT(
		CLK : IN  STD_LOGIC;
		RST : IN  STD_LOGIC;
		AIN : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		AOT : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		DIN : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		DOT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		STR : IN  STD_LOGIC;
		STT : OUT STD_LOGIC;
		WEN : OUT STD_LOGIC;
		OEN : OUT STD_LOGIC
	);
END COMPONENT;

-- Connecting signals linking the two components
SIGNAL ADDR_BUS : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DATA_BUS : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL STR_WIRE : STD_LOGIC;
SIGNAL STT_WIRE : STD_LOGIC;

BEGIN

-- Link up the LEDs to the Reset Button (KEY0) and the most recently
-- received byte in the UART (DRX)
LEDR <= KEY;
LEDG <= ADDR_BUS;

uart_inst : UART1
PORT MAP(
	CLK => CLOCK_50,
	RST => KEY(0),
	RXD => UART_RXD,
	DRX => ADDR_BUS,
	DTX => DATA_BUS,
	TXD => UART_TXD,
	STR => STR_WIRE,
	STT => STT_WIRE
);

sram_inst : SRAM
PORT MAP(
	CLK => CLOCK_50,
	RST => KEY(0),
	AIN => ADDR_BUS,
	AOT => SRAM_ADDR,
	DIN => SRAM_DQ,
	DOT => DATA_BUS,
	STR => STR_WIRE,
	STT => STT_WIRE,
	WEN => SRAM_WE_N,
	OEN => SRAM_OE_N
);

END rtl;