/* Written by: Alex Twilla
   
   Date: 17 Nov 2020
   
   Description: A simple debouncer. Outputs the state of the input after it 
   has remained constant for a given amount of clock cycles.
*/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
  generic(debounce_cycles : integer := 1000000);
  
  port(btn_in, clk : in std_logic;
       btn_db : out std_logic);
end debouncer;

architecture Behavioral of debouncer is

  signal prev_state, out_state : std_logic := '0';
  signal held_cycles : integer range 0 to debounce_cycles := 0;
   
begin


  process(clk)
  begin
    if rising_edge(clk) then
    
      -- Count cycles that button stays in the same state.
      if btn_in = prev_state then
        held_cycles <= held_cycles + 1;
      else
        prev_state <= btn_in;
        held_cycles <= 0;
      end if;
      
    end if;
  end process;
  
  process(held_cycles, clk)
  begin
    if rising_edge(clk) then
      if held_cycles = debounce_cycles then
        out_state <= prev_state;
      end if;
    end if;
  end process;
  
  btn_db <= out_state;

end Behavioral;
