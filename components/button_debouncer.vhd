/*
Written by: Samantha Zimmermann
2 November 2020

Synopsis: This code debounces the five buttons on the BASYS3 FPGA, and returns
a debounced signal.
*/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity button_debouncer is
    Port ( ibtnc : in STD_LOGIC;
           ibtnU : in STD_LOGIC;
           ibtnD : in STD_LOGIC;
           ibtnL : in STD_LOGIC;
           ibtnR : in STD_LOGIC;
           
           obtnc : out STD_LOGIC;
           obtnU : out STD_LOGIC;
           obtnD : out STD_LOGIC;
           obtnL : out STD_LOGIC;
           obtnR : out STD_LOGIC;
           clk : in STD_LOGIC);
end button_debouncer;

architecture Behavioral of button_debouncer is
    signal c, U, D, L, R : std_logic_vector(3 downto 0) := "0000";
begin

    -- Debounce the btnc button press
    debounce_c : process(clk)
    begin
        if rising_edge(clk) then
            c(0) <= ibtnc;
            c(1) <= c(0); 
            c(2) <= c(1);
            c(3) <= c(2);
            c(4) <= c(3);
        end if;
    end process debounce_c;
    
    -- Debounce the btnU
    debounce_U : process(clk)
    begin
        if rising_edge(clk) then
            U(0) <= ibtnU;
            U(1) <= U(0); 
            U(2) <= U(1);
            U(3) <= U(2);
            U(4) <= U(3);
        end if;
    end process debounce_U;

    -- Debounce the btnD
    debounce_D : process(clk)
    begin
        if rising_edge(clk) then
            D(0) <= ibtnD;
            D(1) <= D(0); 
            D(2) <= D(1);
            D(3) <= D(2);
            D(4) <= D(3);
        end if;
    end process debounce_D;
    
    -- Debounce the btnL
    debounce_L : process(clk)
    begin
        if rising_edge(clk) then
            L(0) <= ibtnL;
            L(1) <= L(0); 
            L(2) <= L(1);
            L(3) <= L(2);
            L(4) <= L(3);
        end if;
    end process debounce_L;
    
    -- Debounce the btnR
    debounce_R : process(clk)
    begin
        if rising_edge(clk) then
            R(0) <= ibtnR;
            R(1) <= R(0); 
            R(2) <= R(1);
            R(3) <= R(2);
            R(4) <= R(3);
        end if;
    end process debounce_R;
   
    obtnc <= c(0) and c(1) and c(2) and c(3) and c(4);
    obtnU <= U(0) and U(1) and U(2) and U(3) and U(4);
    obtnD <= D(0) and D(1) and D(2) and D(3) and D(4);
    obtnL <= L(0) and L(1) and L(2) and L(3) and L(4);
    obtnR <= R(0) and R(1) and R(2) and R(3) and R(4);

end Behavioral;
