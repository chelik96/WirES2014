library ieee;
use ieee.std_logic_1164.ALL;

-- PISO - Parallel In, Serial Out Shift Register. Component of Transmitter (tx).
entity piso is
  generic (bits:positive:=8);
  port(  
    clk  : in std_logic;                         -- Master Clock
    we   : in std_logic;                         -- Write Enable           			
    pin  : in std_logic_vector(bits-1 downto 0); -- Parallel In		
    sout : out std_logic                         -- Serial Out
  );         				
end piso;

architecture arch of piso is
  signal sr  : std_logic_vector (bits-1 downto 0);
begin

  process(clk)
    variable c: positive range 1 to bits+1 := 1;
  begin
    if rising_edge(clk) then
	   -- write enabled mode; put the current parallel input in the shift register and reset
	   if (we = '1') then
        sr   <= pin;		
		  sout <= '1'; 
		  c    := 1;
		-- write disabled mode; output the shift register
	   else
		  -- stay high if no more input to process
        if (c > bits) then 	
          sout <= '1';
        -- output next bit of shift register
		  else
		    sout <= sr(0);
          sr   <= '0' & sr(bits-1 downto 1);
          c    := c + 1;
        end if;	
      end if;
    end if;
  end process;
  
end arch;