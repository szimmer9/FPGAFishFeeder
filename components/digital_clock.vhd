/*
Written by: Alex Twilla
29 Oct 2020

Synopsis: This entity functions as a basic digital clock with adjustable time.
To adjust the time, the ld_en input must be set to high, and you must proved a 
valid hour (1 - 12) and minute (0 - 59) via the hr_start and min_start inputs.
The pm_start input indicates whether or not the time is AM ('0') or PM ('1'). 
This code reads from outputs, so VHDL 2008 is required.
*/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity digital_clock is

  port (hr_start, min_start : in std_logic_vector (5 downto 0);
        pm_start, ld_en : in std_logic;
        clk : in std_logic; -- To work properly, clk must be 1Hz, but leaving this open makes testing easier. 
        hr_out, min_out : out std_logic_vector (5 downto 0);
        pm_out : out std_logic);
       
end digital_clock;

architecture Behavioral of digital_clock is

  signal sec_int : std_logic_vector (5 downto 0) := "111111";
  signal pm_int : std_logic := '0';
  
begin
  
  process (clk)
    variable hr, min : integer;
  begin
    hr := to_integer(unsigned(hr_start));
    min := to_integer(unsigned(min_start));
    
    if rising_edge(clk) then
    
      if (hr <= 12) and (hr > 0) and (min <= 59) and ld_en = '1' then
        hr_out <= hr_start;
        min_out <= min_start;
        pm_out <= pm_start;
        sec_int <= "000000";
      
      elsif unsigned(sec_int) = 59 then
        -- End of minute reached. Set back seconds to zero and check minute.
        sec_int <= "000000";
        
        if unsigned(min_out) = 59 then
          -- End of hour reached. Set back mins to zero and check hour.
          min_out <= "000000";
          
          if unsigned(hr_out) = 11 then
            -- Indicate PM or AM.
            pm_out <= not pm_out;
            hr_out <= "001100";
            
          elsif unsigned(hr_out) = 12 then
            -- Loop back to 1 once 12 o'clock completed.
            hr_out <= "000001";
            
          else
            hr_out <= std_logic_vector(unsigned(hr_out) + 1);
          end if;
          
        else
          min_out <= std_logic_vector(unsigned(min_out) + 1);
        end if;
        
      -- Prevent seconds from counting when given invalid start time.
      elsif sec_int /= "111111" then 
        sec_int <= std_logic_vector(unsigned(sec_int) + 1);
      end if;
      
    end if;
    
  end process;

end Behavioral;
