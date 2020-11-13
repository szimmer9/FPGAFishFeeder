/*
Written by: Samantha Zimmermann and Zachary Dunlap
2 November 2020

Synopsis: This code controls the seven-segment display, and includes an 
input to control flashing the display on and off.

This code was adapted from what is available on fpga4student.com.
*/
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity seven_segment_display is
    Port ( clock_100Mhz : in STD_LOGIC;-- 100Mhz clock on Basys 3 FPGA board
           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 3 Anode signals
           LED_out : out STD_LOGIC_VECTOR (6 downto 0);-- Cathode patterns of 7-segment display
           displayed_number : in STD_LOGIC_VECTOR (12 downto 0);--3-digit number to be displayed
           flash : in STD_LOGIC);--controls if flashing on and off
end seven_segment_display;

architecture Behavioral of seven_segment_display is
    signal one_second_counter: STD_LOGIC_VECTOR (27 downto 0);
    -- counter for generating 1-second clock enable
    signal one_second_enable: std_logic;
    -- one second enable for counting numbers
    signal LED_BCD: STD_LOGIC_VECTOR (3 downto 0);
    signal refresh_counter: STD_LOGIC_VECTOR (19 downto 0);
    signal flash_counter: STD_LOGIC_VECTOR (25 downto 0);
    signal flash_enable: STD_LOGIC_VECTOR (1 downto 0);
    -- creating 10.5ms refresh period
    signal LED_activating_counter: std_logic_vector(1 downto 0);
    signal hr4b1, hr4b2, min4b1, min4b2: std_logic_vector(3 downto 0);
    -- the other 2-bit for creating 4 LED-activating signals
    -- count         0    ->  1  ->  2  ->  3
    -- activates    LED1    LED2   LED3   LED4
    -- and repeat
    component bcd_time_converter is
        port(en, clk : in std_logic;
           hr_6bit, min_6bit : in std_logic_vector (5 downto 0);
           hr_4bit1, hr_4bit2, min_4bit1, min_4bit2 : out std_logic_vector (3 downto 0)
        );
    end component;
    begin
    
    bittime: bcd_time_converter
        port map(   en => '1',
                    clk => clock_100Mhz,
                    hr_6bit => displayed_number(12 downto 7),
                    min_6bit => displayed_number(6 downto 1),
                    hr_4bit1 => hr4b1,
                    hr_4bit2 => hr4b2,
                    min_4bit1 => min4b1,
                    min_4bit2 => min4b2);
                    
    
    -- VHDL code for BCD to 7-segment decoder
    -- Cathode patterns of the 7-segment LED display 
    process(LED_BCD)
    begin
        case LED_BCD is
        when "0000" => LED_out <= "0000001"; -- "0"     
        when "0001" => LED_out <= "1001111"; -- "1" 
        when "0010" => LED_out <= "0010010"; -- "2" 
        when "0011" => LED_out <= "0000110"; -- "3" 
        when "0100" => LED_out <= "1001100"; -- "4" 
        when "0101" => LED_out <= "0100100"; -- "5" 
        when "0110" => LED_out <= "0100000"; -- "6" 
        when "0111" => LED_out <= "0001111"; -- "7" 
        when "1000" => LED_out <= "0000000"; -- "8"     
        when "1001" => LED_out <= "0000100"; -- "9" 
    
        when others => LED_out <= "0110000"; -- Display "E" for error when not a digit
        end case;
    end process;
    
    -- 7-segment display controller
    -- generate refresh period of 10.5ms
    process(clock_100Mhz)
    begin 
        if(rising_edge(clock_100Mhz)) then
            refresh_counter <= refresh_counter + 1;
            if(flash = '1') then
                flash_counter <= flash_counter + 1;
            else
                flash_counter(25 downto 24) <= "11";
            end if;
        end if;
    end process;
     LED_activating_counter <= refresh_counter(19 downto 18);
     flash_enable <= flash_counter(25 downto 24);
    
    -- 4-to-1 MUX to generate anode activating signals for 4 LEDs 
    process(LED_activating_counter)
    begin
        case flash_enable is
        when "00" =>
            Anode_Activate <= "1111";
        when "01" =>
            Anode_Activate <= "1111";
        when others =>
            case LED_activating_counter is
            when "00" =>
                Anode_Activate <= "0111"; 
                -- activate LED1 and Deactivate LED2, LED3, LED4
                LED_BCD <= hr4b1;
                -- the first hex digit of the 16-bit number
            when "01" =>
                Anode_Activate <= "1011"; 
                -- activate LED2 and Deactivate LED1, LED3, LED4
                LED_BCD <= hr4b2;
                -- the second hex digit of the 16-bit number
            when "10" =>
                Anode_Activate <= "1101"; 
                -- activate LED3 and Deactivate LED2, LED1, LED4
                LED_BCD <= min4b1;
                -- the third hex digit of the 16-bit number
            when "11" =>
                Anode_Activate <= "1110"; 
                -- activate LED4 and Deactivate LED2, LED3, LED1
                LED_BCD <= min4b2;
                -- the fourth hex digit of the 16-bit number    
            end case;
        end case;
    end process;
    
end Behavioral;