library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Author - Amith Nanjesh

entity SAE_CRC_CALC_SENT_tb is
end entity SAE_CRC_CALC_SENT_tb;

architecture tb of SAE_CRC_CALC_SENT_tb is
  signal nibble0, nibble1, crc : std_logic_vector(3 downto 0);
begin
  dut : entity work.SAE_CRC_CALC_SENT
    port map (
      nibble0 => nibble0,
    nibble1 => nibble1,
      output_crc => crc
    );

  process
  begin
  nibble0 <= "0000";
nibble1 <= "0000";
    wait for 10 us;

  nibble0 <= "0001";
nibble1 <= "1111";
    wait for 10 us;

  nibble0 <= "0101";
nibble1 <= "1010";
    wait for 10 us;

  nibble0 <= "1111";
nibble1 <= "1111";
    wait for 10 us;

    wait;
  end process;
end architecture tb;
