library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edge_detector_tb is
end edge_detector_tb;

architecture Behavioral of edge_detector_tb is
  signal clk, input, r_edge : std_logic := '0';
begin

  ed: entity work.edge_detector
    port map(clk => clk, input => input, edge => r_edge);
    
  process
  begin
    wait for 0.5ns;
    clk <= not clk;
  end process;
  
  process
  begin
    wait for 2 ns;
    input <= not input;
  end process;

end Behavioral;
