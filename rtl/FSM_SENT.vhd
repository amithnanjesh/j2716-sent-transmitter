library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--Author => Amith Nanjesh

entity FSM_SENT is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        pwm_sent_out : in STD_LOGIC;
        fsm_out_signal : out STD_LOGIC_VECTOR(2 downto 0)
    );
end FSM_SENT;

architecture Behavioral of FSM_SENT is
    type state_type is (sync, status, data0, data1, crc);
    signal current_state : state_type;

begin
    process (clk, rst) is
begin
        if rst = '0' then
            current_state <= sync;
        else
		if rising_edge(clk) then
            case current_state is
                when sync =>
                    if pwm_sent_out = '1' then
                        current_state <= status;
                    end if;
                when status =>
                   if pwm_sent_out = '1' then
                        current_state <= data0;
                    end if;
                when data0 =>
                    if pwm_sent_out = '1' then
                        current_state <= data1;
                    end if;
                when data1 =>
                   if pwm_sent_out = '1' then
                        current_state <= crc;
                    end if;
                when crc =>
                     if pwm_sent_out = '1' then
                        current_state <= sync;
                    end if;
            end case;
        end if;
    end if;

end process;



    process (current_state) is
    begin
 
        case current_state is
            when sync =>
                fsm_out_signal <= "000";
            when status =>
                fsm_out_signal <= "001";
            when data0 =>
                fsm_out_signal <= "010";
            when data1 =>
                fsm_out_signal <= "011";
            when crc => 
                fsm_out_signal <= "100";
            when others =>
                fsm_out_signal <= "000";  -- Default case
        end case;
    end process;



end Behavioral;

