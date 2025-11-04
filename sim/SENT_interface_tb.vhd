library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SENT_interface_tb is
end entity SENT_interface_tb;

architecture tb of SENT_interface_tb is
  signal CLK_tb : STD_LOGIC := '0';
  signal RESn_tb : STD_LOGIC := '1';  -- Active low reset
  signal SENT_tb : STD_LOGIC;
  signal Threshold_tb : UNSIGNED(5 downto 0) := (others => '0');
  signal DATA0_tb : std_logic_vector(3 downto 0);
  signal DATA1_tb : std_logic_vector(3 downto 0) ;
  signal sync_tb : std_logic_vector(5 downto 0) ;
  signal status_tb : std_logic_vector(5 downto 0);
  signal NEXT_Out_tb :  STD_LOGIC;
 


begin
   dut: entity work.SENT_interface
    port map (
      CLK => CLK_tb,
      RESn => RESn_tb,
      SENT => SENT_tb,
      Threshold => Threshold_tb,
      DATA0 => DATA0_tb,
      DATA1 => DATA1_tb,
      sync => sync_tb,
      status => status_tb,
      NEXT_Out => NEXT_Out_tb
    );

 
  CLK_process: process
  begin
    while now < 500 us loop
      CLK_tb <= not CLK_tb;
      wait for 0.5 us;  
    end loop;
  end process;


  RESn_process: process
  begin
   
    RESn_tb <= '0';
    wait for 1 us;
    RESn_tb <= '1';
    wait;
end process;

stimulus_process : process
begin
        
    DATA0_tb <= "0000";
    DATA1_tb <= "0000";
    sync_tb <= "101100";
    status_tb <= "000000";
	
    wait for 110 us;

   
     DATA0_tb <= "0001";
    DATA1_tb <= "1111";
    sync_tb <= "101100";
    status_tb <= "000000";
	
    wait for 121 us;


    DATA0_tb <= "0101";
    DATA1_tb <= "1010";
    sync_tb <= "101100";
    status_tb <= "000000";
	
    wait for 129 us;
    DATA0_tb <= "1111";
    DATA1_tb <= "1111";
    sync_tb <= "101100";
    status_tb <= "000000";
	
    wait for 134 us;


  wait;
  end process;
	
stimulus_threshold : process
begin
 Threshold_tb <= "000100";

    wait;
  end process;

end architecture tb;

