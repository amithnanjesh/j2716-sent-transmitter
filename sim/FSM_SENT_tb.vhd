library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Author => Amith Nanjesh


entity FSM_SENT_tb is
end FSM_SENT_tb;

architecture tb of FSM_SENT_tb is
    signal clk, rst, pwm_sent_out_tb : STD_LOGIC := '0';
    signal fsm_out_signal_tb : STD_LOGIC_VECTOR(2 downto 0);

begin
    dut : entity work.FSM_SENT
    port map (
        clk => clk,
        rst => rst,
        pwm_sent_out => pwm_sent_out_tb,
        fsm_out_signal => fsm_out_signal_tb
    );

    -- Clock Generation Process
    clk_process : process
    begin
        while now < 400 us loop  -- Simulate for 400 us
            clk <= not clk;
            wait for 0.5 us;  -- Adjust the clock period as needed
        end loop;
        wait;
    end process;

    
    reset_process : process
    begin
        rst <= '0';
        wait for 1 us;
        rst <= '1';
        wait;
    end process;

   -- Stimulus Process with Loop
stimulus_process : process
begin
    -- Loop to generate stimulus
    for i in 1 to 3 loop
        pwm_sent_out_tb <= '0';  
        wait for 57 us;

        pwm_sent_out_tb <= '1';  
        wait for 1 us;

        pwm_sent_out_tb <= '0';  
        wait for 12 us;

        pwm_sent_out_tb <= '1';  
        wait for 1 us;

        pwm_sent_out_tb <= '0';  
        wait for 12 us;

        pwm_sent_out_tb <= '1';  
        wait for 1 us;

        pwm_sent_out_tb <= '0';  
        wait for 12 us;
	
	pwm_sent_out_tb <= '1';  
        wait for 1 us;

        pwm_sent_out_tb <= '0';  
        wait for 18 us;

	pwm_sent_out_tb <= '1';  
        wait for 1 us;

    end loop;

    wait;  
end process;

  
    simulation_stop : process
    begin
        wait for 400 us;  -- Simulate for 400 us
        report "Simulation finished" severity note;
        wait;
    end process;

end tb;

