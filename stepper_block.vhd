/*  Written by: Alex Twilla

    Date: 17 Nov 2020
    
    Synopsis: This module controls a stepper via an FSM implementation. The 
      num_steps generic determines the number of steps taken when a rising 
      edge is detected from stepper_trigger. The step_interval generic 
      determines how the rest period between steps. The operation of the 
      stepper is not affected by toggling stepper_trigger mid-rotation. 
*/

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity stepper_block is
  generic(num_steps : integer := 200;
          step_interval : integer := 1000000);
  
  port(stepper_trigger, stepper_trigger2, clk : in std_logic;
       step_out : out std_logic_vector (3 downto 0));
end stepper_block;

/*  Port Description:
      stepper_trigger: activates stepper rotation.
      clk: system clock.
      step_out: output signal sent to PMOD STEP.
      
        (3) -> SIG5
        (2) -> SIG6
        (1) -> SIG7
        (0) -> SIG8
*/

architecture Behavioral of stepper_block is

  type fsm_state is (idle, step1, step2, step3, step4);
  signal curr_state, next_state : fsm_state := idle;
  
  signal cycles : integer range 0 to step_interval := 0;
  signal steps : integer range 0 to num_steps := 0;
  
  signal t1, t2, t3, r_edge_trigger : std_logic;
  
begin

  detect_edge: process(clk)
  begin
    -- Synchronize trigger to avoid implementation issues.
    if rising_edge(clk) then
      t1 <= stepper_trigger or stepper_trigger2;
      t2 <= t1;
      t3 <= t2;
      r_edge_trigger <= t2 and not t3;
    end if;
  end process detect_edge;

  next_state_logic: process(clk)
  begin
    -- Reset steps on transition to idle state, increment otherwise.
    -- Leave steps unchanged on transitions from idle state.
    -- Check steps count after every step.
    -- Reset cycle count when next state differs from curr_state.
    if rising_edge(clk) then
      if curr_state = idle then
        if r_edge_trigger then
          next_state <= step1;
        end if;
        
      elsif curr_state = step1 then
        if cycles = step_interval then
          next_state <= step2;
          steps <= steps + 1;
        elsif steps = num_steps then
          next_state <= idle;
          steps <= 0;
        end if;
        
      elsif curr_state = step2 then
        if cycles = step_interval then
          next_state <= step3;
          steps <= steps + 1;
        elsif steps = num_steps then
          next_state <= idle;
          steps <= 0;
        end if;
        
      elsif curr_state = step3 then
        if cycles = step_interval then
          next_state <= step4;
          steps <= steps + 1;
        elsif steps = num_steps then
          next_state <= idle;
          steps <= 0;
        end if;
      
      elsif curr_state = step4 then  
        if cycles = step_interval then
          next_state <= step1;
          steps <= steps + 1;
        elsif steps = num_steps then
          next_state <= idle;
          steps <= 0;
        end if;
        
      else
        next_state <= idle;
      end if;
    end if;
  end process next_state_logic;
  
  update_state: process(next_state, clk)
  begin
    curr_state <= next_state;
  end process update_state;
  
  output_function: process(curr_state, clk)
  begin
    if rising_edge(clk) then
      if curr_state = idle then
        cycles <= 0;
        step_out <= "0000";
        
      elsif curr_state = step1 then
        cycles <= cycles + 1;
        step_out <= "0101";
        
        if next_state /= curr_state then
          cycles <= 0;
        end if;
        
      elsif curr_state = step2 then
        cycles <= cycles + 1;
        step_out <= "0110";
        
        if next_state /= curr_state then
          cycles <= 0;
        end if;
        
      elsif curr_state = step3 then
        cycles <= cycles + 1;
        step_out <= "1010";
        
        if next_state /= curr_state then
          cycles <= 0;
        end if;
        
      elsif curr_state = step4 then
        cycles <= cycles + 1;
        step_out <= "1001";
        
        if next_state /= curr_state then
          cycles <= 0;
        end if;
        
      else
        cycles <= 0;
        step_out <= "0000";
      end if;
    end if;
  end process output_function;
  
end Behavioral;
