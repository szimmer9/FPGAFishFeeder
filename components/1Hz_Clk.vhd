/*
Written by: Alex Twilla
28 Oct 2020

Synopsis: This is a design that slows the Basys3's 100 MHz clock down to 1 Hz.
The output of this design will be fed to our clock design.
*/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Clk_1Hz is
  generic(count_lim : integer := 100000000);
  port(clk : in std_logic := '1';
       clk_1Hz : out std_logic := '0');
end Clk_1Hz;

architecture Behavioral of Clk_1Hz is
  signal counts : integer range 0 to 100000000 := 0;
begin

  process (clk)
  begin
  
    if rising_edge(clk) then
    
      if counts = count_lim then
        clk_1Hz <= '1';
        counts <= 0;
      else
        counts <= counts + 1;
        clk_1Hz <= '0';
      end if;
      
    end if;
    
  end process;
  
end Behavioral;
