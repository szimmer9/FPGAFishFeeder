library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity time_controller_tb is
end time_controller_tb;

architecture Behavioral of time_controller_tb is
  signal inc, dec, hr_min_sel, en, reset : std_logic := '0';
  signal hr, min : std_logic_vector(5 downto 0);
begin

  en <= '1';
  
  time_ctrl: entity work.time_controller
    port map(inc => inc,
             dec => dec,
             hr_min_sel => hr_min_sel,
             en => en,
             reset => reset,
             hr => hr,
             min => min);
  
  process
  begin
    wait for 0.5 ns;
    dec <= not dec;
  end process;
  
  process
  begin
    wait for 100 ns;
    hr_min_sel <= not hr_min_sel;
  end process;
  
  process
  begin
    wait for 200 ns;
    reset <= not reset;
  end process;

end Behavioral;
