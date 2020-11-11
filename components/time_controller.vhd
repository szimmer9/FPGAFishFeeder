/* Written by: Alex Twilla
   Date: 8 Nov 2020
   Description: This component allows the user to set the minute 
     and hour of a time depending on the value of a selector input. It 
     uses two int_controller components to accomplish this.
*/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity time_controller is
 port (hr_inc, hr_dec, min_inc, min_dec, pm_in, en, reset : in std_logic;
       hr, min : out std_logic_vector (5 downto 0);
       pm_out : out std_logic);
end time_controller;

architecture Behavioral of time_controller is

begin

  process(pm_in)
  begin
    if en = '1' then
      pm_out <= pm_in;
    end if;
  end process;

  hr_controller: entity work.int_controller
    generic map(int_lower => 1,
                int_upper => 12,
                num_out_msb => 5,
                num_out_lsb => 0)
                
    port map(inc => hr_inc,
             dec => hr_dec,
             en => en,
             reset => reset,
             num_out => hr);
             
  min_controller : entity work.int_controller
    generic map(int_lower => 0,
                int_upper => 59,
                num_out_msb => 5,
                num_out_lsb => 0)
                
    port map(inc => min_inc,
             dec => min_dec,
             en => en,
             reset => reset,
             num_out => min);                                           

end Behavioral;
