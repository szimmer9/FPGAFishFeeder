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
  generic (int_lower : integer := 0;
           int_upper : integer := 9;
           num_out_msb : integer := 3;
           num_out_lsb : integer := 0);
           
  port (en, reset, inc, dec, clk : in std_logic;
        num_out : out std_logic_vector (num_out_msb downto num_out_lsb));
end int_controller;

architecture Behavioral of int_controller is

  signal int : integer range int_lower to int_upper := int_lower;
  signal inc_edge, dec_edge : std_logic := '0';
  
begin
 
  e1: entity work.edge_detector
    port map(clk => clk, input => inc, edge => inc_edge);
    
  e2: entity work.edge_detector
    port map(clk => clk, input => dec, edge => dec_edge);   

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        int <= int_lower;
    
      elsif inc_edge = '1' and en = '1' then
        if int = int_upper then
          int <= int_lower;
        else
          int <= int + 1;
        end if;
  
      elsif dec_edge = '1' and en = '1' then
        if int = int_lower then
          int <= int_upper;
        else
          int <= int - 1;
        end if;
      end if;
      
      num_out <= std_logic_vector(to_unsigned(int, num_out_msb - num_out_lsb + 1));
    end if;
  end process;

end Behavioral;
