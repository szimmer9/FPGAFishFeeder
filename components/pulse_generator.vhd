/* Written by: Alex Twilla
   
   Date: 16 Nov 2020
   
   Synopsis: This module generates a pulse of duration len clock cycles, where 
     len is some integer upon a rising edge of pulse_in.
*/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pulse_generator is
  generic(len : integer := 100000000);
  
  port(pulse_in, clk : in std_logic;
       pulse_out : out std_logic);
end pulse_generator;

architecture Behavioral of pulse_generator is

  type fsm_state is (waiting, counting);
  signal curr_state, next_state : fsm_state := waiting;
  signal p1, p2, p3, r_edge_p : std_logic := '0';
  signal cycles : integer range 0 to len := 0;

begin
  
  detect_edge: process(clk)
  begin
    if rising_edge(clk) then
      p1 <= pulse_in;
      p2 <= p1;
      p3 <= p2;
      r_edge_p <= p2 and not p3;
    end if;
  end process detect_edge;
  
  next_state_logic: process(clk)
  begin
    if rising_edge(clk) then
      if curr_state = waiting then
        if r_edge_p then
          next_state <= counting;
        end if;
      
      elsif curr_state = counting then
        if cycles = len then
          next_state <= waiting;
        end if;
      end if;
    end if;
  end process next_state_logic;
  
  update_state: process(next_state, clk)
  begin
    if rising_edge(clk) then
      curr_state <= next_state;
    end if;
  end process update_state;
  
  output_function: process(clk)
  begin
    if rising_edge(clk) then
      if curr_state = counting then
        cycles <= cycles + 1;
        pulse_out <= '1';
      elsif curr_state = waiting then
        cycles <= 0;
        pulse_out <= '0';
      else
        cycles <= 0;
        pulse_out <= '0';
      end if;
    end if;
  end process output_function;

end Behavioral;
