library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


--Author => Amith Nanjesh

entity MUX_SENT_tb is
end MUX_SENT_tb;

architecture tb of MUX_SENT_tb is
       signal sync_tb, stat_tb, d1_tb, d0_tb, crc4_tb : STD_LOGIC_VECTOR(5 downto 0);
       signal select_line_tb : STD_LOGIC_VECTOR(2 downto 0);
        signal output_mux_tb : STD_LOGIC_VECTOR(5 downto 0);
	signal clk_tb : STD_LOGIC := '0';

    component MUX_SENT
        Port (
            clk : in STD_LOGIC;
            sync : in STD_LOGIC_VECTOR(5 downto 0);
            stat : in STD_LOGIC_VECTOR(5 downto 0);
            d1 : in STD_LOGIC_VECTOR(5 downto 0);
            d0 : in STD_LOGIC_VECTOR(5 downto 0);
            crc4 : in STD_LOGIC_VECTOR(5 downto 0);
            select_line : in STD_LOGIC_VECTOR(2 downto 0);
            output_mux : out STD_LOGIC_VECTOR(5 downto 0)
        );
    end component;

begin
    dut : MUX_SENT
        port map (
            clk => clk_tb,
            sync => sync_tb,
            stat => stat_tb,
            d1 => d1_tb,
            d0 => d0_tb,
            crc4 => crc4_tb,
            select_line => select_line_tb,
            output_mux => output_mux_tb
        );

    clk_process : process
    begin
        while now < 400 us loop  -- Simulate for 400 us
            clk_tb <= not clk_tb;
            wait for 0.5 us;  
        end loop;
        wait;
    end process;

    stimulus_process : process
    begin
        while now < 400 us loop
            select_line_tb <= "000";
            sync_tb <= "101100";
            stat_tb <= "000000";
            d0_tb <= "001111";
            d1_tb <= "001111";
            crc4_tb <= "001111";
            wait for 50 us;
            

            
            select_line_tb <= "001";
             sync_tb <= "101100";
            stat_tb <= "000000";
            d0_tb <= "001111";
            d1_tb <= "001111";
            crc4_tb <= "001111";
            wait for 50 us;
            
           
            
            select_line_tb <= "010";
             sync_tb <= "101100";
            stat_tb <= "000000";
            d0_tb <= "001111";
            d1_tb <= "001111";
            crc4_tb <= "001111";
            wait for 50 us;
            
            

            
            select_line_tb <= "011";
              sync_tb <= "101100";
            stat_tb <= "000000";
            d0_tb <= "001111";
            d1_tb <= "001111";
            crc4_tb <= "001111";
            wait for 50 us;
            
                      
            select_line_tb <= "100";
             sync_tb <= "101100";
            stat_tb <= "000000";
            d0_tb <= "001111";
            d1_tb <= "001111";
            crc4_tb <= "001111";
            wait for 50 us;
            
            
        end loop;

        wait;
    end process;

end tb;

