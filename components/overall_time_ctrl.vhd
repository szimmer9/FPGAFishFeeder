library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity overall_time_ctrl is
  generic(sys_time_op : std_logic_vector (4 downto 0) := "00001";
          feed1_op : std_logic_vector (4 downto 0) := "00010";
          feed2_op : std_logic_vector (4 downto 0) := "00100";
          feed3_op : std_logic_vector (4 downto 0) := "01000");
  
  port(hr_inc, hr_dec, min_inc, min_dec, pm, en, reset : in std_logic;
       opcode : in std_logic_vector (4 downto 0);
       sys_time, feed_time1, feed_time2, feed_time3 : out std_logic_vector (12 downto 0));
       
end overall_time_ctrl;

architecture Behavioral of overall_time_ctrl is

  signal sys_en, feed1_en, feed2_en, feed3_en : std_logic := '0';
  
begin

  --sys_en <= en when opcode = sys_time_op else '0';
  --feed1_en <= en when opcode = feed1_op else '0';
  --feed2_en <= en when opcode = feed2_op else '0';
  --feed3_en <= en when opcode = feed3_op else '0';

process (opcode)
  begin  
  case opcode is
  
    when sys_time_op =>
      sys_en <= en;
      feed1_en <= '0';
      feed2_en <= '0';
      feed3_en <= '0';
      
    when feed1_op =>
      sys_en <= '0';
      feed1_en <= en;
      feed2_en <= '0';
      feed3_en <= '0';
      
    when feed2_op =>
      sys_en <= '0';
      feed1_en <= '0';
      feed2_en <= en;
      feed3_en <= '0';
      
    when feed3_op =>
      sys_en <= '0';
      feed1_en <= '0';
      feed2_en <= '0';
      feed3_en <= en;
      
    when others =>
      sys_en <= '0';
      feed1_en <= '0';
      feed2_en <= '0';
      feed3_en <= '0';
      
  end case;
  end process;

  sys_time_ctr: entity work.time_controller
    port map(hr_inc => hr_inc,
             hr_dec => hr_dec,
             min_inc => min_inc,
             min_dec => min_dec,
             pm_in => pm,
             en => sys_en,
             reset => reset,
             hr => sys_time(12 downto 7),
             min => sys_time(6 downto 1),
             pm_out => sys_time(0));

  feed1_time_ctr: entity work.time_controller
    port map(hr_inc => hr_inc,
             hr_dec => hr_dec,
             min_inc => min_inc,
             min_dec => min_dec,
             pm_in => pm,
             en => feed1_en,
             reset => reset,
             hr => feed_time1(12 downto 7),
             min => feed_time1(6 downto 1),
             pm_out => feed_time1(0));
             
  feed2_time_ctr: entity work.time_controller
    port map(hr_inc => hr_inc,
             hr_dec => hr_dec,
             min_inc => min_inc,
             min_dec => min_dec,
             pm_in => pm,
             en => feed2_en,
             reset => reset,
             hr => feed_time2(12 downto 7),
             min => feed_time2(6 downto 1),
             pm_out => feed_time2(0));
             
  feed3_time_ctr: entity work.time_controller
    port map(hr_inc => hr_inc,
             hr_dec => hr_dec,
             min_inc => min_inc,
             min_dec => min_dec,
             pm_in => pm,
             en => feed3_en,
             reset => reset,
             hr => feed_time3(12 downto 7),
             min => feed_time3(6 downto 1),
             pm_out => feed_time3(0));
                                    
end Behavioral;
