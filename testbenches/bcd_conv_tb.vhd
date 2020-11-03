----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/03/2020 02:19:22 PM
-- Design Name: 
-- Module Name: bcd_conv_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcd_conv_tb is
end bcd_conv_tb;

architecture Behavioral of bcd_conv_tb is
  signal en : std_logic := '1';
  signal clk : std_logic := '0';
  signal hr_6bit, min_6bit : std_logic_vector (5 downto 0) := "000000";
  signal hr_4bit1, hr_4bit2, min_4bit1, min_4bit2 : std_logic_vector (3 downto 0);
begin

  bcd: entity work.bcd_time_converter
    port map(en => en,
             clk => clk,
             hr_6bit => hr_6bit,
             min_6bit => min_6bit,
             hr_4bit1 => hr_4bit1,
             hr_4bit2 => hr_4bit2,
             min_4bit1 => min_4bit1,
             min_4bit2 => min_4bit2);

  process
  begin
    wait for 1 ns;
    clk <= not clk;
  end process;
  
  process
  begin
    wait for 2 ns;
    
    if min_6bit /= "111011" then
      min_6bit <= std_logic_vector(unsigned(min_6bit) + 1);
    else
      min_6bit <= "000000";
    end if;
  end process;
  
  process
  begin
    wait for 120 ns;
    
    if hr_6bit /= "001100" then
      hr_6bit <= std_logic_vector(unsigned(hr_6bit) + 1);
    else
      hr_6bit <= "000001";
    end if;
  end process;

end Behavioral;
