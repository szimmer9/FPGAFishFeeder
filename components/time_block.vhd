-- Written by: Alex Twilla
-- Date: 12 Nov 2020
-- Synopsis: This is the high-level time module for the FPGA fish feeder.
--  Based on the given opcode, this component allows one to set the system 
--  time or any of the three feeding times, outputting this time as a 13-bit 
--  vector. In the base state, the component simply outputs the system time. 
--  This component also triggers the feeding protocol whenever the system time 
--  matches any of the three feeding times, assuming they are enabled. 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity time_block is
  
  generic(base_state : std_logic_vector (4 downto 0) := "00000";
          set_sys_time : std_logic_vector (4 downto 0) := "00001";
          set_f1_time : std_logic_vector (4 downto 0) := "00010";
          set_f2_time : std_logic_vector (4 downto 0) := "00100";
          set_f3_time : std_logic_vector (4 downto 0) := "01000");
  
  port(hr_inc, hr_dec, min_inc, min_dec, pm, reset, clk : in std_logic;
       f1_enable, f2_enable, f3_enable : in std_logic;
       opcode : in std_logic_vector (4 downto 0);
       time_out : out std_logic_vector (12 downto 0);
       stepper_trigger : out std_logic);
       
end time_block;


architecture Behavioral of time_block is

  signal sys_start_time, sys_time, feed_time1, feed_time2, feed_time3 : std_logic_vector (12 downto 0);
  signal clk_1hz, clock_ld_en : std_logic;

begin

  -- This component handles setting the times. Opcode determines which 
  -- times respond to input.
  time_ctrl: entity work.overall_time_ctrl
    generic map(sys_time_op => set_sys_time,
                feed1_op => set_f1_time,
                feed2_op => set_f2_time,
                feed3_op => set_f3_time)
  
    port map(hr_inc => hr_inc,
             hr_dec => hr_dec,
             min_inc => min_inc,
             min_dec => min_dec,
             pm => pm,
             en => '1',
             reset => reset,
             clk => clk,
             opcode => opcode,
             sys_time => sys_start_time,
             feed_time1 => feed_time1,
             feed_time2 => feed_time2,
             feed_time3 => feed_time3);
             
             
  -- Simple counter that produces a rising edge every second. 
  second_counter: entity work.Clk_1Hz
    port map(clk => clk,
             clk_1hz => clk_1hz);
             
  
  -- Clock that updates the system time.
  clock: entity work.digital_clock
    port map(hr_start => sys_start_time(12 downto 7),
             min_start => sys_start_time(6 downto 1),
             pm_start => sys_start_time(0),
             ld_en => clock_ld_en,
             clk => clk_1hz,
             hr_out => sys_time(12 downto 7),
             min_out => sys_time (6 downto 1),
             pm_out => sys_time(0));
             
             
  -- Output appropriate time based on opcode. Enable loads on digital_clock 
  -- entity if needed.
  set_display_time: process (opcode, clk)
  begin
    if rising_edge(clk) then
    
      case opcode is
        when base_state =>
          clock_ld_en <= '0';
          time_out <= sys_time;
        when set_sys_time =>
          clock_ld_en <= '1';
          time_out <= sys_time;
        when set_f1_time =>
          clock_ld_en <= '0';
          time_out <= feed_time1;
        when set_f2_time =>
          clock_ld_en <= '0';
          time_out <= feed_time2;
        when set_f3_time =>
          clock_ld_en <= '0';
          time_out <= feed_time3;
        when others =>
          clock_ld_en <= '0';
          time_out <= sys_time;
      end case;
      
    end if;
  end process set_display_time;
  
  
  -- This process triggers the stepper whenever the system time equals
  -- any of the feeding times and these times are not disabled.
  trigger_stepper: process (sys_time, feed_time1, feed_time2, feed_time3, clk)
  begin
    if rising_edge(clk) then
      if sys_time = feed_time1 and f1_enable = '1' then
        stepper_trigger <= '1';
      
      elsif sys_time = feed_time2 and f2_enable = '1' then
        stepper_trigger <= '1';
      
      elsif sys_time = feed_time3 and f3_enable = '1' then
        stepper_trigger <= '1';
      
      else
        stepper_trigger <= '0';
      
      end if;
    end if;
  end process;               
                          
                                                                     
end Behavioral;
