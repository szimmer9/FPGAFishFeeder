/*  Written by: Alex Twilla

    Date: 18 Nov 2020
    
    Synopsis: A simple module for detecting rising edges from an asynchronous 
      input. Useful for when multiple inputs may affect the same output.
*/
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edge_detector is

  port (clk, input : in std_logic;
        edge : out std_logic);
        
end edge_detector;

architecture Behavioral of edge_detector is

  signal shift_reg : std_logic_vector (2 downto 0) := "000";
  
begin

  process(clk)
  begin
    if rising_edge(clk) then
      shift_reg(0) <= input;
      shift_reg(1) <= shift_reg(0);
      shift_reg(2) <= shift_reg(1);
      edge <= shift_reg(1) and not shift_reg(2);
    end if;
  end process;

end Behavioral;
