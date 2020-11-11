----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2020 04:13:42 PM
-- Design Name: 
-- Module Name: overall_time_ctrl_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity overall_time_ctrl_tb is
end overall_time_ctrl_tb;

architecture Behavioral of overall_time_ctrl_tb is

  signal hr_inc, hr_dec, min_inc, min_dec, pm, reset : std_logic := '0';
  signal en, pm_out : std_logic := '1';
  signal opcode : std_logic_vector (4 downto 0) := "00001";
  signal sys_time, feed_time1, feed_time2, feed_time3 : std_logic_vector (12 downto 0);
  signal sys_hr, sys_min, f1_hr, f1_min, f2_hr, f2_min, f3_hr, f3_min : std_logic_vector (5 downto 0);
  
begin

  otc: entity work.overall_time_ctrl
    port map(hr_inc => hr_inc,
             hr_dec => hr_dec,
             min_inc => min_inc,
             min_dec => min_dec,
             pm => pm,
             en => en,
             reset => reset,
             opcode => opcode,
             sys_time => sys_time,
             feed_time1 => feed_time1,
             feed_time2 => feed_time2,
             feed_time3 => feed_time3);
  
  sys_hr <= sys_time(12 downto 7);
  sys_min <= sys_time(6 downto 1);
  
  f1_hr <= feed_time1(12 downto 7);
  f1_min <= feed_time1(6 downto 1);
  
  f2_hr <= feed_time2(12 downto 7);
  f2_min <= feed_time2(6 downto 1);
  
  f3_hr <= feed_time3(12 downto 7);
  f3_min <= feed_time3(6 downto 1);
             
  process
  begin
    wait for 0.5 ns;
    min_inc <= not min_inc;
    hr_inc <= not hr_inc;
    pm <= not pm;
  end process;
  
  process
  begin
    wait for 40 ns;
    
    case opcode is
      when "00001" =>
        opcode <= "00010";
        pm_out <= feed_time1(0);
      when "00010" =>
        opcode <= "00100";
        pm_out <= feed_time2(0);
      when "00100" =>
        opcode <= "01000";
        pm_out <= feed_time3(0); 
      when "01000" =>
        opcode <= "00001";
        pm_out <= sys_time(0); 
      when others => opcode <= "00001";
    end case;
  end process;      

end Behavioral;
