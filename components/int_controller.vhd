/* Written by: Alex Twilla
   Date: 4 Nov 2020
   Description: This entity allows one to increment or decrement an integer 
     between some min and max values. This integer is output as a 
     std_logic_vector, the size of which is determined by the user.
*/
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity int_controller is
  generic (int_lower, int_upper : integer;
           num_out_msb, num_out_lsb : integer);
           
  port (en, reset, inc, dec : in std_logic;
        num_out : out std_logic_vector (num_out_msb downto num_out_lsb));
end int_controller;

architecture Behavioral of int_controller is
  signal int : integer range int_lower to int_upper := int_lower;
begin

  process(inc, dec, reset)
  begin
    
    if inc = '1' and en = '1' then
      if int = int_upper then
        int <= int_lower;
      else
        int <= int + 1;
      end if;
  
    elsif dec = '1' and en = '1' then
      if int = int_lower then
        int <= int_upper;
      else
        int <= int - 1;
      end if;
  
    elsif reset = '1' then
      int <= int_lower;
    end if;
  end process;
  
  num_out <= std_logic_vector(to_unsigned(int, num_out_msb - num_out_lsb + 1));

end Behavioral;
