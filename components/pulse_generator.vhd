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

  signal active : std_logic := '0';
  signal cycles : integer range 0 to len := 0;

begin

  process(pulse_in, clk)
  begin
    if rising_edge(pulse_in) then
      active <= '1';
    elsif cycles = 0 and falling_edge(clk) then
      -- Falling edge to ensure count updates first.
      active <= '0';
    end if;
  end process;
  
  process(active, clk)
  begin
    if active = '1' and rising_edge(clk) then
      
      if cycles = len - 1 then
        cycles <= 0;
      else
        cycles <= cycles + 1;
        pulse_out <= '1';
      end if;
    elsif active = '0' then
      pulse_out <= '0';
    end if;
  end process;
  

end Behavioral;
