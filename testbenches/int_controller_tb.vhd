library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity int_controller_tb is
end int_controller_tb;

architecture Behavioral of int_controller_tb is
  signal clk : std_logic := '0';
  signal en, inc, dec, reset : std_logic := '1';
  signal hr_out, min_out : std_logic_vector (5 downto 0) := "000000";
begin
  reset <= '0';
  dec <=  '0';
  
  hr_ctrl: entity work.int_controller
    generic map(int_lower => 1,
                int_upper => 12,
                num_out_msb => 5,
                num_out_lsb => 0)
                
    port map(en => en,
             inc => inc,
             dec => dec,
             reset => reset,
             num_out => hr_out,
             clk => clk);   
             
  min_ctrl: entity work.int_controller
    generic map(int_lower => 0,
                int_upper => 59,
                num_out_msb => 5,
                num_out_lsb => 0)
                
    port map(en => en,
             inc => inc,
             dec => dec,
             reset => reset,
             num_out => min_out,
             clk => clk);
             
  process
  begin
    wait for 0.5 ns;
    clk <= not clk;
  end process;
  
  process
  begin
    wait for 1 ns;
    inc <= not inc;
  end process;

end Behavioral;
