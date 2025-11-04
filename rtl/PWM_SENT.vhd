library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_SENT is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        threshold : in UNSIGNED(5 downto 0);
        reload_value : in UNSIGNED(5 downto 0);
        sent_signal : out STD_LOGIC;
        pwm_sent_out : out STD_LOGIC := '0'
    );
end PWM_SENT;

architecture Behavioral of PWM_SENT is
    signal count_out : UNSIGNED(7 downto 0) := (others => '0');  -- Signal for controlling count reset
begin
    process (clk, rst) is
    begin
        if rising_edge(clk)  then
                 if (rst = '0')  then
                     count_out <= (others => '0');
                     sent_signal <= '1';
		
            else
                      if count_out >= reload_value - 1  then
                         count_out <= "00000000";  -- Reset count_out when count equals reload_value
               else
                         count_out <= count_out + 1 ;  -- Update count_out normally
                     if  count_out   < threshold then
                         sent_signal <='0';
				
		else
		          sent_signal <= '1';
                         end if;
	          
                      end if;
			
                 end if;
            end if;
    end process;



    generate_PWM_sent_out : process(clk)
    begin
                if rising_edge(clk) then
                if count_out  = reload_value - 1  then
                    pwm_sent_out <= '1';
            else
                  pwm_sent_out <= '0';
               end if;
           end if;
    end process;

end Behavioral;

