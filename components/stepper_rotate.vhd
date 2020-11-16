/* Written by: Alex Twilla

   Date: 15 Nov 2020
   
   Synopsis: This module rotates a stepper motor connected to a BASYS3 board
     via the PMOD STEP peripheral. The stepper that is used here steps 1.80 
     degrees per step. This code steps once, wait ~0.01 seconds and setps 
     again, leading to a rotation period of roughly two seconds. When 
     specifying the constraints for this project, ensure the following 
     connections are made:
     
       step_out(3) -> SIG5 on PMOD
       step_out(2) -> SIG6 on PMOD
       step_out(1) -> SIG7 on PMOD
       step_out(0) -> SIG8 on PMOD
*/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity stepper_rotate is
  port(en, clk : in std_logic;
       step_out : out std_logic_vector (3 downto 0) := "0000");
end stepper_rotate;

/* Port Descriptions:
     en: Can be a switch or button. Rotates stepper when high.
     clk: BASYS3's onboard clock (100 MHz).
     step_out: signals sent to PMOD STEP.
*/

architecture Behavioral of stepper_rotate is

  signal sigs : std_logic_vector (3 downto 0) := "0000";
  -- 20 bit vector for a step interval of roughly 1 mill clock cycles.
  signal cycles : std_logic_vector (19 downto 0) := "00000000000000000000";

begin

  step_interval: process(clk)
  begin
    if rising_edge(clk) then
      cycles <= std_logic_vector(unsigned(cycles) + 1);
    end if;
  end process step_interval;
  
  update_signals: process(cycles, clk)
  begin
    if unsigned(cycles) = 0 and rising_edge(clk) then
      case sigs is
        when "0101" => sigs <= "0110";
        when "0110" => sigs <= "1010";
        when "1010" => sigs <= "1001";
        when "1001" => sigs <= "0101";
        when others => sigs <= "0101";
      end case;
    end if;
  end process update_signals;
  
  step: process(sigs, clk)
  begin
    if en = '1'  and rising_edge(clk) then
      step_out <= sigs;
    end if;
  end process step;

end Behavioral;
