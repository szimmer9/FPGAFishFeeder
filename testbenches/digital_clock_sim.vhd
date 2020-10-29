/*
Written by: Alex Twilla
29 Oct 2020

Synopsis: A basic testbench used for testing the digital_clock entity.
*/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity digital_clock_sim is
end digital_clock_sim;

architecture Behavioral of digital_clock_sim is

  signal clk, pm_in, pm_out : std_logic := '0';
  signal hr_in, min_in : std_logic_vector (5 downto 0);
  signal hr_out, min_out : std_logic_vector (5 downto 0);
  signal hr_int, min_int : integer;
  signal ld_en : std_logic := '1';
  
begin

  digi_clock: entity work.digital_clock
    port map(hr_start => hr_in,
             min_start => min_in,
             pm_start => pm_in,
             clk => clk,
             ld_en => ld_en,
             hr_out => hr_out,
             min_out => min_out,
             pm_out => pm_out);
               

  hr_in <= "000001";
  min_in <= "000000";

  process
  begin
    wait for 60 us;
    ld_en <= '0';
  end process;
            
  process
  begin
    wait for 0.5 ns;
    clk <= not clk;
  end process;             

  hr_int <= to_integer(unsigned(hr_out));
  min_int <= to_integer(unsigned(min_out));

end Behavioral;
