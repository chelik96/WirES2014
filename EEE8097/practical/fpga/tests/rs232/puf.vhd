-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 13.0.0 Build 156 04/24/2013 SJ Web Edition"
-- CREATED		"Thu Sep 18 10:04:12 2014"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY puf IS 
	PORT
	(
		UART_RXD :  IN  STD_LOGIC;
		CLOCK_50 :  IN  STD_LOGIC;
		KEY :  IN  STD_LOGIC_VECTOR(0 TO 0);
		SRAM_DQ :  IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		UART_TXD :  OUT  STD_LOGIC;
		SRAM_WE_N :  OUT  STD_LOGIC;
		SRAM_OE_N :  OUT  STD_LOGIC;
		SRAM_UB_N :  OUT  STD_LOGIC;
		SRAM_LB_N :  OUT  STD_LOGIC;
		LEDG :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		LEDR :  OUT  STD_LOGIC_VECTOR(0 TO 0);
		SRAM_ADDR :  OUT  STD_LOGIC_VECTOR(17 DOWNTO 0)
	);
END puf;

ARCHITECTURE bdf_type OF puf IS 

COMPONENT uart1
	PORT(CLK : IN STD_LOGIC;
		 nRES : IN STD_LOGIC;
		 RXD : IN STD_LOGIC;
		 STBT : IN STD_LOGIC;
		 DT : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TXD : OUT STD_LOGIC;
		 STBR : OUT STD_LOGIC;
		 nRDY : OUT STD_LOGIC;
		 DR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT puf_wrapper
	PORT(CLK : IN STD_LOGIC;
		 nRES : IN STD_LOGIC;
		 STBR : IN STD_LOGIC;
		 nRDY : IN STD_LOGIC;
		 Ain : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 Dmem : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 STBT : OUT STD_LOGIC;
		 nWE : OUT STD_LOGIC;
		 nOE : OUT STD_LOGIC;
		 nUB : OUT STD_LOGIC;
		 nLB : OUT STD_LOGIC;
		 Amem : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		 Dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(7 DOWNTO 0);


BEGIN 
LEDR <= KEY;
LEDG <= SYNTHESIZED_WIRE_4;



b2v_inst : uart1
PORT MAP(CLK => CLOCK_50,
		 nRES => KEY(0),
		 RXD => UART_RXD,
		 STBT => SYNTHESIZED_WIRE_0,
		 DT => SYNTHESIZED_WIRE_1,
		 TXD => UART_TXD,
		 STBR => SYNTHESIZED_WIRE_2,
		 nRDY => SYNTHESIZED_WIRE_3,
		 DR => SYNTHESIZED_WIRE_4);


b2v_inst1 : puf_wrapper
PORT MAP(CLK => CLOCK_50,
		 nRES => KEY(0),
		 STBR => SYNTHESIZED_WIRE_2,
		 nRDY => SYNTHESIZED_WIRE_3,
		 Ain => SYNTHESIZED_WIRE_4,
		 Dmem => SRAM_DQ,
		 STBT => SYNTHESIZED_WIRE_0,
		 nWE => SRAM_WE_N,
		 nOE => SRAM_OE_N,
		 nUB => SRAM_UB_N,
		 nLB => SRAM_LB_N,
		 Amem => SRAM_ADDR,
		 Dout => SYNTHESIZED_WIRE_1);


END bdf_type;