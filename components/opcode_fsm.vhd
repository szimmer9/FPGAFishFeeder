/*
Written by: Samantha Zimmermann
2 November 2020

Synopsis: This is the main design that controls the state machine of an
automatic fish feeder.
*/
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity opcode_fsm is
    port( op : in std_logic_vector(4 downto 0) := "00000";
          ft_enable : out std_logic_vector(2 downto 0) := "000";
          am_pm : out std_logic := '0';
          LED_nodes : out std_logic_vector(6 downto 0) := "0000000";
          Anode : out std_logic_vector(3 downto 0) := "0000";
          btnc, btnL, btnR, btnU, btnD : in std_logic;
          clock : in std_logic);
end entity;

architecture main of opcode_fsm is

    --Controls display of time
    component seven_segment_display is
        port ( clock_100Mhz : in STD_LOGIC;-- 100Mhz clock on Basys 3 FPGA board
               Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 3 Anode signals
               LED_out : out STD_LOGIC_VECTOR (6 downto 0);-- Cathode patterns of 7-segment display
               displayed_number : in STD_LOGIC_VECTOR (15 downto 0);--4-digit number to be displayed    
               flash : in STD_LOGIC );--Flag to control flashing of the 7-seg display digits   
    end component seven_segment_display; 
    
    --Debounce the 5 button presses 
    component button_debouncer is
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
               clk : in STD_LOGIC );
    end component button_debouncer;
    --Clock control
    component digital_clock is
      port( hr_start, min_start : in std_logic_vector (5 downto 0);
            pm_start, ld_en : in std_logic;
            clk : in std_logic; -- To work properly, clk must be 1Hz, but leaving this open makes testing easier. 
            hr_out, min_out : out std_logic_vector (5 downto 0);
            pm_out : out std_logic );
    end component digital_clock;
    --Slows down board clock
    component Clk_1Hz is
      generic(count_lim : integer := 9999999);
      port( clk : in std_logic := '1';
            clk_1Hz : out std_logic := '0');
    end component Clk_1Hz;
    
    signal cp, Up, Dp, Rp, Lp : std_logic := '0';
    signal digits_to_display : std_logic_vector(15 downto 0);
    signal flash_enable : std_logic := '0';
    signal current_state : std_logic_vector(4 downto 0) := "0000";
    signal curr_hour, curr_min : std_logic_vector(5 downto 0) := "000000";
    signal ft1_hour, ft2_hour, ft3_hour : std_logic_vector(5 downto 0) := "000000";
    signal ft1_min, ft2_min, ft3_min : std_logic_vector(5 downto 0) := "000000";
    signal slow_clock : std_logic := '1';
begin

    -- Controls debouncing of all button presses
    debounce : button_debouncer 
    port map( ibtnc => btnc,
              ibtnU => btnU,
              ibtnD => btnD, 
              ibtnL => btnL, 
              ibtnR => btnR,
              obtnc => cp,
              obtnU => Up,
              obtnD => Dp,
              obtnL => Lp,
              obtnR => Rp,
              clk => clock);
    -- Controls seven-segment display
    sseg : seven_segment_display
    port map( clock_100Mhz => clock,
              Anode_Activate => Anode, 
              LED_out => LED_nodes,
              displayed_number => digits_to_display,
              flash => flash_enable );
    -- Time module
    keep_time : digital_clock
    port map( hr_start => "000000",
              min_start => "000000",
              pm_start => '0',
              ld_en => '0',
              hr_out => curr_hour,
              min_out => curr_min,
              clk => slow_clock );
    -- Slows down the board clock to 1Hz
    onehz_clock : Clk_1Hz
    port map( clk => clock,
              clk_1hz => slow_clock );
              
    fsm : process(cp)
        variable reset_count : integer := 0; --implement multiple presses to clear? 3x?
    begin
        if rising_edge(cp) then
            if current_state = op then--perform toggling
                case current_state is
                    when "00001" => am_pm <= not am_pm;
                    when "00010" => ft_enable(0) <= not ft_enable(0);
                    when "00100" => ft_enable(1) <= not ft_enable(1);
                    when "01000" => ft_enable(2) <= not ft_enable(2);
                    when "10000" => --clear everything
                        curr_hour <= "00000";
                        curr_min  <= "00000";
                        ft1_hour  <= "00000";
                        ft1_min   <= "00000";
                        ft2_hour  <= "00000";
                        ft2_min   <= "00000";
                        ft3_hour  <= "00000";
                        ft3_min   <= "00000";
                        am_pm     <= '0';
                        ft_enable <= "000";                        
                end case;
            else 
                case current_state is--switching the state based on op
                    when "00000" =>--normal operation
                        if op = "00001" or op = "00010" or op = "00100" or op = "01000" then
                            current_state <= op;
                            flash_enable <= '1';
                        end if;
                    when "00001" | "00010" | "00100" | "01000" =>--set time
                        if op = "00000" then
                            current_state <= "00000";
                            flash_enable <= '0';
                        end if;--otherwise, do nothing
                end case; 
            end if;
        end if;
    end process fsm;

    change_set_time : process(Up, Dp, Lp, Rp)
    begin
            if rising_edge(Up) then--increase minute
               case current_state is
                    when "00001" => curr_min <= std_logic_vector(unsigned(curr_min) + 1);
                    when "00010" => ft1_min <= std_logic_vector(unsigned(curr_min) + 1);
                    when "00100" => ft2_min <= std_logic_vector(unsigned(curr_min) + 1);
                    when "01000" => ft3_min <= std_logic_vector(unsigned(curr_min) + 1);
                end case;
            elsif rising_edge(Dp) then--decrease minute
                case current_state is
                    when "00001" => curr_min <= std_logic_vector(unsigned(curr_min) - 1);
                    when "00010" => ft1_min <= std_logic_vector(unsigned(curr_min) - 1);
                    when "00100" => ft2_min <= std_logic_vector(unsigned(curr_min) - 1);
                    when "01000" => ft3_min <= std_logic_vector(unsigned(curr_min) - 1);
                end case;
            elsif rising_edge(Lp) then--increase hour
                case current_state is
                    when "00001" => curr_hour <= std_logic_vector(unsigned(curr_min) + 1);
                    when "00010" => ft1_hour <= std_logic_vector(unsigned(curr_min) + 1);
                    when "00100" => ft2_hour <= std_logic_vector(unsigned(curr_min) + 1);
                    when "01000" => ft3_hour <= std_logic_vector(unsigned(curr_min) + 1);
                end case;
            elsif rising_edge(Rp) then--decrease hour
                case current_state is
                    when "00001" => curr_hour <= std_logic_vector(unsigned(curr_min) - 1);
                    when "00010" => ft1_hour <= std_logic_vector(unsigned(curr_min) - 1);
                    when "00100" => ft2_hour <= std_logic_vector(unsigned(curr_min) - 1);
                    when "01000" => ft3_hour <= std_logic_vector(unsigned(curr_min) - 1);
                end case;
            end if;
    end process change_set_time;
    
    --Controls what digit is sent to the 7-seg display
    --Need to set up BCD
    set_digit : process
    begin
        case current_state is
            when "00000" =>
                
            when "00001" =>
            
            when "00010" => 
            
            when "00100" => 
            
            when "01000" =>
        end case;
    end process set_digit;
    
end architecture main;