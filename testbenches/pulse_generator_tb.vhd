library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pulse_generator_tb is
end pulse_generator_tb;

architecture Behavioral of pulse_generator_tb is

  signal clk, pulse_in, pulse_out, active : std_logic := '0';
  signal pulse_out1, pulse_out2 : std_logic := '0';

begin

  pulse_gen: entity work.pulse_generator
    generic map(len => 5)
    
    port map(clk => clk,
             pulse_in => pulse_in,
             pulse_out => pulse_out);
             
  pulse_gen1: entity work.pulse_generator
    generic map(len => 50)
    
    port map(clk => clk,
             pulse_in => pulse_in,
             pulse_out => pulse_out1);
             
  pulse_gen2: entity work.pulse_generator
    generic map(len => 100)
    
    port map(clk => clk,
             pulse_in => pulse_in,
             pulse_out => pulse_out2);                          
             
  process
  begin
    wait for 0.5 ns;
    clk <= not clk;
  end process;
  
  pulse_in <= '1'; 
  active <= << signal pulse_gen.active : std_logic >>;

end Behavioral;
