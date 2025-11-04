library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Author: Amith Nanjesh

entity SENT_interface is
  port (
    CLK : in STD_LOGIC;
    RESn : in STD_LOGIC;
    SENT : out STD_LOGIC;
    Threshold : in UNSIGNED(5 downto 0);
    DATA0 : in std_logic_vector(3 downto 0);
    DATA1 : in std_logic_vector(3 downto 0);
    sync : in std_logic_vector(5 downto 0);
    status : in std_logic_vector(5 downto 0);
    NEXT_Out : out STD_LOGIC
  );
end entity SENT_interface;

architecture behavioral of SENT_interface is
   signal zero : STD_LOGIC := '0';
   signal reload_internal : UNSIGNED(5 downto 0);
   signal mux_internal : STD_LOGIC_VECTOR(5 downto 0);
   signal crc6bit : std_logic_vector(5 downto 0);
   signal d0 : std_logic_vector(5 downto 0);
   signal d1 : std_logic_vector(5 downto 0);
   signal select_line_mux : STD_LOGIC_VECTOR(2 downto 0);
   signal crc4bit : std_logic_vector(3 downto 0);


  component MUX_SENT is
    port (
      clk : in STD_LOGIC;
      sync : in STD_LOGIC_VECTOR(5 downto 0);
      stat : in STD_LOGIC_VECTOR(5 downto 0);
      d0 : in STD_LOGIC_VECTOR(5 downto 0);
      d1 : in STD_LOGIC_VECTOR(5 downto 0);
      crc4 : in STD_LOGIC_VECTOR(5 downto 0);
      select_line : in STD_LOGIC_VECTOR(2 downto 0);
      output_mux : out STD_LOGIC_VECTOR(5 downto 0)
    );
  end component;

  component PWM_SENT is
    Port (
      CLK : in STD_LOGIC;
      rst : in STD_LOGIC;
      threshold : in UNSIGNED(5 downto 0);
      reload_value : in UNSIGNED(5 downto 0);
      sent_signal : out STD_LOGIC;
      pwm_sent_out : out STD_LOGIC := '0'
    );
  end component;

  component FSM_SENT is
    Port (
      clk : in STD_LOGIC;
      rst : in STD_LOGIC;
      pwm_sent_out : in STD_LOGIC;
      fsm_out_signal : out STD_LOGIC_VECTOR(2 downto 0)
    );
  end component;

  component SAE_CRC_CALC_SENT is
    port (
      nibble0 : in std_logic_vector(3 downto 0);
      nibble1 : in std_logic_vector(3 downto 0);
      output_crc : out std_logic_vector(3 downto 0)
    );
  end component;

begin
  MUX_SENT_inst : MUX_SENT
    port map (
      d0 => d0,
      d1 => d1,
      crc4 =>crc6bit,
      sync => sync,
      stat => status,
      output_mux => mux_internal,
      clk => CLK,
      select_line => select_line_mux
    );

  PWM_SENT_inst : PWM_SENT
    port map (
      clk => CLK,
      rst => RESn,
      threshold => Threshold,
      reload_value => reload_internal,
      sent_signal => SENT,
      pwm_sent_out => zero
    );

  FSM_SENT_inst : FSM_SENT
    port map (
      clk => CLK,
      rst => RESn,
      pwm_sent_out => zero,
      fsm_out_signal => select_line_mux
    );

  SAE_CRC_CALC_SENT_inst : SAE_CRC_CALC_SENT
    port map (
      nibble0 => DATA0,
      nibble1 => DATA1,
      output_crc => crc4bit 
    );


  reload_internal <= unsigned(mux_internal) + "001100";




Decoder_process : process (select_line_mux)
    begin
        case select_line_mux is
            when "000" =>
                NEXT_Out <= '1';  
            when "001" =>
                NEXT_Out <= '0';  
            when "010" =>
                NEXT_Out <= '0'; 
		 when "011" =>
                NEXT_Out <= '0';
            when "100" =>
                NEXT_Out <= '0';
            when others =>
                NEXT_Out <= '0';  
        end case;
    end process;

d0 <= "00" & DATA0;
d1 <= "00" & DATA1;
crc6bit <= "00" & crc4bit;
end architecture behavioral;

