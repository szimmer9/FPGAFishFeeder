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
          ft_enable : in std_logic_vector(2 downto 0) := "000"; -- switches
          ft_1, ft_2, ft_3 : out std_logic := '0'; -- LEDs to indicate active
          manual_override : in std_logic := '0'; -- switch
          am_pmIN : in std_logic := '0';
          am_pm : out std_logic := '0';
          LED_nodes : out std_logic_vector(6 downto 0) := "0000000";
          Anode : out std_logic_vector(3 downto 0) := "0000";
          btnc, btnL, btnR, btnU, btnD : in std_logic;
          stepper_ctrl : out std_logic_vector(3 downto 0) := "0000";
          clock : in std_logic);
end entity;

architecture main of opcode_fsm is
    --Controls display of time
    component seven_segment_display is
        port ( clock_100Mhz : in STD_LOGIC;-- 100Mhz clock on Basys 3 FPGA board
               Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 3 Anode signals
               LED_out : out STD_LOGIC_VECTOR (6 downto 0);-- Cathode patterns of 7-segment display
               displayed_number : in STD_LOGIC_VECTOR (12 downto 0);--Number to be displayed
               flash : in STD_LOGIC );--Flag to control flashing of the 7-seg display digits   
    end component seven_segment_display; 
    
    --Debounce the 5 button presses, one for each
    component debouncer is
        Port( btn_in, clk : in std_logic;
              btn_db : out std_logic );
    end component debouncer;
    
    --Slows down board clock
    component Clk_1Hz is
      generic(count_lim : integer := 9999999);
      port( clk : in std_logic := '1';
            clk_1Hz : out std_logic := '0');
    end component Clk_1Hz;
    
    -- Controls current time and feeding times
    component time_block is
      generic(base_state : std_logic_vector (4 downto 0) := "00000";
              set_sys_time : std_logic_vector (4 downto 0) := "00001";
              set_f1_time : std_logic_vector (4 downto 0) := "00010";
              set_f2_time : std_logic_vector (4 downto 0) := "00100";
              set_f3_time : std_logic_vector (4 downto 0) := "01000");
      port(hr_inc, hr_dec, min_inc, min_dec, pm, reset, clk : in std_logic;
           f1_enable, f2_enable, f3_enable : in std_logic;
           opcode : in std_logic_vector (4 downto 0);
           time_out : out std_logic_vector (12 downto 0);
           stepper_trigger : out std_logic);
    end component;
    
    -- Controls the motor through PMOD attachment
    component stepper_block is
      generic(num_steps : integer := 200;
              step_interval : integer := 1000000);
      port(stepper_trigger, clk : in std_logic;
           step_out : out std_logic_vector (3 downto 0));
    end component;
    
    component edge_detector is
        port(clk, input : in std_logic;
            edge : out std_logic);
    end component;
    
    signal inc_hour, dec_hour, inc_min, dec_min, cen : std_logic := '0'; -- signals to handle changing time
    signal reset_flag : std_logic := '0';
    signal time_to_display : std_logic_vector (12 downto 0);
    signal stepper_go, stepper_go2, flash_enable : std_logic := '0';
    signal cenEdge : std_logic := '0';
    signal current_state : std_logic_vector (4 downto 0) := "00000";
begin
    -- Debounce the 5 button presses
    debounce_hour_up : debouncer port map( btn_in => btnU,
                                           clk => clock,
                                           btn_db => inc_hour);
    debounce_hour_down : debouncer port map( btn_in => btnD,
                                             clk => clock,
                                             btn_db => dec_hour);
    debounce_min_up : debouncer port map( btn_in => btnR,
                                          clk => clock,
                                          btn_db => inc_min );                                       
    debounce_min_down : debouncer port map( btn_in => btnL,
                                            clk => clock,
                                            btn_db => dec_min );
    debounce_center : debouncer port map( btn_in => btnC,
                                          clk => clock,
                                          btn_db => cen);                                                                        
    -- Maintain times and time adjustments
    keep_time : time_block port map( hr_inc => inc_hour,
                                     hr_dec => dec_hour,
                                     min_inc => inc_min,
                                     min_dec => dec_min,
                                     pm => am_pmIN,
                                     reset => reset_flag,
                                     clk => clock,
                                     f1_enable => ft_enable(0),
                                     f2_enable => ft_enable(1),
                                     f3_enable => ft_enable(2),
                                     opcode => current_state,
                                     time_out => time_to_display,
                                     stepper_trigger => stepper_go );
                                     
    motor_control : stepper_block port map( stepper_trigger => stepper_go or stepper_go2, 
                                            clk => clock,
                                            step_out => stepper_ctrl );
                                                          
    sseg : seven_segment_display port map( clock_100Mhz => clock,
                                           Anode_Activate => Anode,
                                           LED_out => LED_nodes,
                                           displayed_number => time_to_display,
                                           flash => flash_enable );
    -- enable LEDs based off switch input
    ft_1 <= ft_enable(0);
    ft_2 <= ft_enable(1);
    ft_3 <= ft_enable(2);
    
    edgedetector : edge_detector port map(  clk => clock,
                                            input => cen,
                                            edge => cenEdge);
                                            
    am_pm <= time_to_display(0);
    
    fsm : process(clock)
    begin
    if(rising_edge(clock)) then
        if(cenEdge = '1') then
            if current_state = "00000" then -- allow switch to a valid state
                 reset_flag <= '0';
                 
                 if op = "00001" or op = "00010" or op = "00100" or op = "01000" then
                    current_state <= op;
                    flash_enable <= '1';
                 elsif op = "10000" then
                    current_state <= op;
                 end if;
            -- if a time change state, can change back to normal state
            elsif (current_state = "00001") or (current_state = "00010") or (current_state = "00100") or (current_state = "01000") then
                reset_flag <= '0';
                
                if op = "00000" then 
                    current_state <= "00000";
                    flash_enable <= '0';
                end if;
            -- if reset and push the center button, 
            elsif current_state = op and op = "10000" then -- reset pulse sent to time_block
                reset_flag <= '1';
                --wait for 10ns;
                --reset_flag <= '0';
            elsif current_state = "10000" and op = "00000" then -- go back to main state
                reset_flag <= '0';
                current_state <= "00000";
            end if;
        else
            if current_state = "00000" then
                -- listen for manual override
                stepper_go2 <= manual_override;
             end if;
        end if;
    end if;
    end process fsm;

end architecture main;