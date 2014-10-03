library ieee;
use ieee.std_logic_1164.all;

-- Receiver Componentserial receives serial, LSB-first data and outputs 8-bit
--  parallel output, after removing start and end bits.
entity rx is
  port(
    clk    : in  std_logic;
	 rst    : in  std_logic := '0';
	 input  : in  std_logic;
    output : out std_logic_vector(7 downto 0)
  );
end rx;

architecture arch of rx is

  -- SIPO shift register
  component sipo is
  port (
    clk  : in  std_logic;
    rdy  : in  std_logic;
    send : in  std_logic;
    sin  : in  std_logic;
    pout : out std_logic_vector(7 downto 0)
  );
  end component;
	 
  -- Counter
  component cnt
    generic (ovf_cnt : integer := 7); -- default overflow count		
  port(
    rst : in  std_logic;
    clk : in  std_logic; 
    ovf : out std_logic
  );
  end component;
  
  -- States of receiver:
  -- Idle     : No action is being performed
  -- Start    : Start bit to input is 1 clock of '1' 
  -- Receive  : Get the 8 data bits (using counter and SIPO components)
  -- Stop     : Stop bit inputed to say we've finished
  type state is (idle, start, receive, stop);
  -- present and the next state
  signal p_state, n_state : state :=idle;
  
  signal sr_clk  : std_logic; -- Clock for SIPO -16 times slower than master clock
  signal sr_rst  : std_logic; -- Resets SIPO
  signal sr_send : std_logic; -- Retrieve output from SIPO
  signal ovflow  : std_logic; -- Flag overflows
  signal old_ovf : std_logic; -- Keep Track of previous overflow to look for rising edge
  signal rst_c   : std_logic; -- Resets counter
  signal reg     : std_logic_vector(7 downto 0) := (others => '1'); -- Tempory store of sipo till needed
  signal i       : integer := 0; -- Keep count of bits seen

begin

  sr: sipo
  port map(
    clk  => sr_clk, 
    rdy  => sr_rst,
    send => sr_send,
    pout => reg,
    sin  => input
  );
	
  count: cnt
  generic map(ovf_cnt => 7)
  port map(
    rst => rst_c,
    clk => clk,
    ovf => ovflow
  );

  trn_proc: process(clk)
  begin
    if (rising_edge(clk)) then
      p_state <= n_state;
    end if;
    -- process a reset
    if (rst = '1') then
      n_state <= idle;
      rst_c   <= '1';
      sr_rst  <= '1';
    else
      -- case analysis of current state
      case p_state is
        -- "idle" state - if serial input goes low we've encountered a start bit
        when idle =>
          if (input = '0') then
            n_state <= start;
            rst_c   <= '0';
            sr_rst  <= '1';
				sr_clk  <= '0';
         end if;

        -- "start state - counter should overflow and we should be in middle of start bit
        -- at this point then change state to "receive" and reset SIPO and index
        when start =>
			 if (sr_rst = '1') then
			   sr_clk <= not sr_clk;
          end if;
          if (ovflow = '1' and input = '0') then
            n_state <= receive;
            sr_clk  <= '1';
            sr_send <= '0';
				sr_rst  <= '0';
            i       <= 0;
          end if;

        -- "receive" state - generate SIPOs clock
		  -- toggle it on 8 Master clocks so 16 times slower
		  -- an overflow when i not 17 means your in the middle of a bit
        when receive =>
          if (ovflow = '1' and old_ovf = '0' and i /= 17) then
            n_state <= receive;
            i       <= i + 1;
            if (sr_clk = '1') then
              sr_clk <= '0';
            else
              sr_clk <= '1';
            end if;
          elsif (ovflow = '1' and i = 17 and input='1') then
            -- Read 8 bits, and in middle of end bit - 
				-- enter "stop" state and set SIPO to output
            n_state <=  stop;
            rst_c   <= '1';
            sr_send <= '1';
            sr_clk <= not sr_clk;			
          end if;
			 old_ovf <= ovflow;

        -- "stop" state - set output from temporary register and go "idle"
        when  stop =>
          n_state <= idle;
          rst_c <= '1';
          output <= reg;

      end case;
    end if;
  end process;

end arch;