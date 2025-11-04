library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--Author => Amith Nanjesh


entity MUX_SENT is
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
end MUX_SENT;

architecture Behavioral of MUX_SENT is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            case select_line is
                when "000" =>  -- sync
                    output_mux <= sync;
                when "001" =>  -- stat
                    output_mux <= stat;
                when "010" =>  -- d1
                    output_mux <= d0;
                when "011" =>  -- d0
                   output_mux <= d1;
                when "100" =>  
                    output_mux <=crc4;
                when others =>
                    output_mux <= (others => '0');  -- Default value
            end case;
        end if;
    end process;


end Behavioral;

