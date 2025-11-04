-- Author: Amith Nanjesh

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CRC4_SENT_tb is
end entity CRC4_SENT_tb;

architecture tb of CRC4_SENT_tb is
  signal data, input_crc, output_crc : std_logic_vector(3 downto 0);
begin
  dut : entity work.CRC4_SENT
    port map (
      data =>data,
      input_crc => input_crc,
      output_crc => output_crc
    );

  process
  begin
   data <= "0000";
    input_crc <= "0101";
    wait for 10 us;

   data <= "0010";
    input_crc <= "0011";
    wait for 10 us;

   data <= "1001";
    input_crc <= "1101";
    wait for 10 us;

    wait;
  end process;
end architecture tb;

