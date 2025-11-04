library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


--Author => Amith Nanjesh
entity PWM_SENT_tb is
end PWM_SENT_tb;

architecture tb of PWM_SENT_tb is
    signal clk, rst : std_logic := '0';
    signal threshold : UNSIGNED(5 downto 0) := (others => '0');
    signal reload_value : UNSIGNED(5 downto 0) := (others => '0');
    signal sent_signal : std_logic;
    signal pwm_sent_out : STD_LOGIC := '0';
    

begin
    dut : entity work.PWM_SENT
        port map (
            clk => clk,
            rst => rst,
            threshold => threshold,
            reload_value => reload_value,
            sent_signal => sent_signal,
	     pwm_sent_out => pwm_sent_out

        );

    clk_process: process
    begin
        while now < 500 us loop
            clk <= not clk;
            wait for 0.5 us;  
        end loop;
        wait;
    end process;

    rst_process: process
    begin
        rst <= '0';
        wait for 1 us;  
        rst <= '1';
        wait;
        end process;

    stimulus_process: process
    begin
     

        threshold <= "000101";   
     
 
	wait for 1 us;
        reload_value <= "111000";  -- Set reload value
        wait for 56 us;  -- Wait for simulation duration
        reload_value <= "001100";  -- Set reload value
        wait for 12 us;  -- Wait for simulation duration
       reload_value <= "001100";  -- Set reload value
         wait for 12 us;
        reload_value <= "001100";  -- Set reload value
         wait for 12 us;
        reload_value <= "010010";  -- Set reload value
           wait for 18 us;
	


	reload_value <= "111000";  -- Set reload value
        wait for 56 us;  -- Wait for simulation duration
        reload_value <= "001100";  -- Set reload value
        wait for 12 us;  -- Wait for simulation duration
        reload_value <= "001101";  -- Set reload value
         wait for 13 us;
        reload_value <= "011011";  -- Set reload value
         wait for 27 us;
        reload_value <= "001101";  -- Set reload value
         wait for 13 us;


       reload_value <= "111000";  -- Set reload value
        wait for 56 us;  -- Wait for simulation duration
       reload_value <= "001100";  -- Set reload value
        wait for 12 us;  -- Wait for simulation duration
       reload_value <= "010001";  -- Set reload value
         wait for 17 us;
       reload_value <= "010110";  -- Set reload value
         wait for 22 us;
       reload_value <= "010110";  -- Set reload value
         wait for 22 us;


	reload_value <= "111000";  -- Set reload value
        wait for 56 us;  -- Wait for simulation duration
        reload_value <= "001100";  -- Set reload value
        wait for 12 us;  -- Wait for simulation duration
        reload_value <= "001100";  -- Set reload value
         wait for 12 us;
        reload_value <= "011011";  -- Set reload value
         wait for 27 us;
        reload_value <= "001100";  -- Set reload value
         wait for 12 us;
     
        wait;
    end process;
end tb;
