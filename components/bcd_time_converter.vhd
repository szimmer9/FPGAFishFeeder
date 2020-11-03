----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/03/2020 01:13:44 PM
-- Design Name: 
-- Module Name: 6bit_bcd_time_converter - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bcd_time_converter is
  port(en, clk : in std_logic;
       hr_6bit, min_6bit : in std_logic_vector (5 downto 0);
       hr_4bit1, hr_4bit2, min_4bit1, min_4bit2 : out std_logic_vector (3 downto 0));
end bcd_time_converter;

architecture Behavioral of bcd_time_converter is

begin

  process (clk)
    variable hr_tens, hr_ones, min_tens, min_ones : integer;
  begin
    if rising_edge(clk) and en = '1' then
      
      if unsigned(hr_6bit) >= 10 then
        hr_tens := 1;
        hr_ones := to_integer(unsigned(hr_6bit)) - 10;
      else
        hr_tens := 0;
        hr_ones := to_integer(unsigned(hr_6bit));
      end if;
      
      min_tens := to_integer(unsigned(min_6bit)) / 10;
      min_ones := to_integer(unsigned(min_6bit)) mod 10;
      
      hr_4bit1 <= std_logic_vector(to_unsigned(hr_tens, 4));
      hr_4bit2 <= std_logic_vector(to_unsigned(hr_ones, 4));
      min_4bit1 <= std_logic_vector(to_unsigned(min_tens, 4));
      min_4bit2 <= std_logic_vector(to_unsigned(min_ones, 4));
      
    end if;
  end process;

end Behavioral;
