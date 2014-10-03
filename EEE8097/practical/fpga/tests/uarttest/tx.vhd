library ieee;
use ieee.std_logic_1164.all;

-- Transmitter Component, sends byte values (received in parallel) out in
-- serial, LSB-first form adding start and stop bits.
entity tx is
  port(
    clk    : in  std_logic;
    rst    : in  std_logic;
    input  : in  std_logic_vector(7 downto 0);
    output : out std_logic;
    send   : in  std_logic; -- send bit high to load and start transfer of parallel input
    sent   : out std_logic  -- this goes high once 8 bits appended to a low start bit are transmitted
  );
end tx;

architecture arch of tx is

  -- PISO shift register
  component piso
  port(
    clk  : in  std_logic;
    we   : in  std_logic;
    pin  : in  std_logic_vector(7 downto 0);
    sout : out std_logic
  );
  end component;
	 
  -- Counter
  component cnt
    generic ( ovf_cnt : integer := 7); -- default overflow count		
  port(
    rst : in  std_logic;
    clk : in  std_logic; 
    ovf : out std_logic
  );
  end component;
    
  -- States of transmitter:
  -- Idle     : No action is being performed
  -- Start    : send one '0' Start bit to input when send is '1' 
  --            and load the parallel input in shift register
  -- Transmit : Transmit the 8 data bits (using Counter and PISO components)
  -- Stop     : send one '1' Stop bit to say we've finished
  type state is (idle, start, transmit, stop);
  -- present and next state
  signal p_state, n_state : state :=idle;

  signal we     : std_logic := '0'; -- load input to shift register
  signal sr_out : std_logic := '1'; -- store the output of shift register
  signal rst_c  : std_logic := '0'; -- reset the counter to 0
  signal ovflow : std_logic := '0'; -- flag an overflow in the counter
  signal p_send : std_logic := '0'; -- keep track of previous send state
begin

  sr: piso
  port map (
    clk  => clk,   -- the input clock is same as transmitter clock
    we   => we,    -- load input from transmitter signals
    pin  => input, -- input of PISO is given from input of transmitter
    sout => sr_out -- the output of PISO is stored to out_temp
  );

  count: cnt
  generic map(ovf_cnt => 7)
  port map(
    rst => rst_c, -- reset the counter to 0
    clk => clk,   -- clock of counter is same as clock of transmitter
    ovf => ovflow -- overflow bit of counter
  );
  
  -- find next state to transition to given present state and inputs
  trn_proc: process(send, rst, p_state, ovflow)
  begin
    -- asynchronus reset - go back to idle
	 if (rst='1') then
      n_state <= idle;
    else 
	   -- Note: this is a case analysis, but altera can't handle 'case' syntax here for some reason
      if (p_state = idle) then
        -- negative edge trigerred - load parallel input and goto 'start' state 
		  if (p_send = '1' and send = '0') then 
          n_state <= start;
          we      <= '1';
        else	
          n_state <= idle;
        end if;
      -- transmission started - update bits outputted, and go to 'transmit' state
      elsif (p_state = start) then
        rst_c   <= '1';
        n_state <= transmit;
        we      <= '0';	
      -- count all bits transmitted, then go to 'stop' after 8 bits
      elsif (p_state = transmit) then
        rst_c <= '0';
        if (ovflow = '1') then
          n_state <= stop;
        else 
          n_state <= transmit;
        end if;
      -- if all data is transferred, go back to idle state
      elsif (p_state = stop) then
        n_state <= idle;
      end if;
		p_send  <= send;
    end if;
  end process;

  -- Set outputs through case analysis of current state
  out_proc: process(clk)
  begin
    if (rising_edge(clk)) then
      -- change present state to next state (for next transition process)
      p_state <= n_state;
      case n_state is
        when idle => 
          output <= '1';
          sent   <= '0';
        when start =>
          output <= '0';
          sent   <= '0';
        when transmit =>
          output <= sr_out;
          sent   <= '0';
        when stop =>
          output <= '1';
          sent   <= '1';
      end case;
    end if;
  end process;

end arch;