-- VHDL Test Bench for shift register  :  sr
LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY sr_vhd_tst IS
END sr_vhd_tst;			-- no ports on testbench, all signals are internal

ARCHITECTURE testbench OF sr_vhd_tst IS
                                                
SIGNAL clk : STD_LOGIC;
SIGNAL enable : STD_LOGIC;
SIGNAL sr_in : STD_LOGIC;
SIGNAL sr_out : STD_LOGIC;

COMPONENT basic_shift_register
	PORT (
	clk : IN STD_LOGIC;
	enable : IN STD_LOGIC;
	sr_in : IN STD_LOGIC;
	sr_out : OUT STD_LOGIC
	);
END COMPONENT;

BEGIN
	uut : basic_shift_register
	PORT MAP (
	clk => clk,
	enable => enable,
	sr_in => sr_in,
	sr_out => sr_out
	);
	
testinputs : PROCESS      -- data to drive inputs                                         
BEGIN                                                        
	enable <= '1';		-- initialise at time zero
	sr_in <= '0';
wait for 200 ns;
	sr_in <= '1';		-- changes after a delay
wait for 200 ns;
	sr_in <= '0'; 
wait;                                                       
END PROCESS testinputs;                                           

clock: process			-- repeating pulse for clock
begin
	for clksteps in 0 to 100 loop	-- stop simulation after fixed number of cycles
    clk <= '0';
    wait for 10 ns;
    clk <= not clk;
    wait for 10 ns;
    -- clock period = 20 ns
    end loop;
wait; 
end process;                                        
END testbench;
