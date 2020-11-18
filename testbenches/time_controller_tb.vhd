library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity time_controller_tb is
end time_controller_tb;

architecture Behavioral of time_controller_tb is
  signal hr_inc, hr_dec, min_inc, min_dec, pm_in, pm_out, en, reset, clk : std_logic := '0';
  signal hr, min : std_logic_vector(5 downto 0);
begin

  en <= '1';
  
  time_ctrl: entity work.time_controller
    port map(hr_inc => hr_inc,
             hr_dec => hr_dec,
             min_inc => min_inc,
             min_dec => min_dec,
             pm_in => pm_in,
             en => en,
             reset => reset,
             hr => hr,
             min => min,
             clk => clk);
  
  process
  begin
    wait for 1 ns;
    hr_dec <= not hr_dec;
    min_inc <= not min_inc;
  end process;
  
  process
  begin
    wait for 0.5 ns;
    clk <= not clk;
  end process;
  
  process
  begin
    wait for 200 ns;
    reset <= not reset;
  end process;

end Behavioral;
