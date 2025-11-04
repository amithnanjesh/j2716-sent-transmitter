library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Author - Amith Nanjesh

entity SAE_CRC_CALC_SENT is
  port (
    nibble0 : in std_logic_vector(3 downto 0);
   nibble1 : in std_logic_vector(3 downto 0);
    output_crc  : out std_logic_vector(3 downto 0)
  );
end entity SAE_CRC_CALC_SENT;

architecture behavioral of SAE_CRC_CALC_SENT is
  signal input_crc : std_logic_vector(3 downto 0) := "0011";
  signal intermediate_crc : std_logic_vector(3 downto 0);
begin
  crc4_1 : entity work.crc4_SENT
    port map (
      data => nibble0,
      input_crc => input_crc,
      output_crc => intermediate_crc
    );

  crc4_2 : entity work.crc4_SENT
    port map (
     data =>nibble1,
      input_crc => intermediate_crc,
      output_crc => output_crc
    );
end architecture behavioral;
