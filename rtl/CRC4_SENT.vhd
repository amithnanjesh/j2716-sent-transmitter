library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Author - Amith Nanjesh

entity CRC4_SENT is
  port (
   data : in std_logic_vector(3 downto 0);
    input_crc  : in std_logic_vector(3 downto 0);
    output_crc : out std_logic_vector(3 downto 0)
  );
end entity CRC4_SENT;

architecture behavioral of CRC4_SENT is
  signal gen_poly : std_logic_vector(3 downto 0) := "1101";
  signal xor_results: std_logic_vector(19 downto 0);

begin
  -- 1st cycle
  xor_results(3 downto 0) <=data xor input_crc;
  xor_results(7 downto 4) <= (gen_poly xor (xor_results(2 downto 0) & '0')) when xor_results(3) = '1' else (xor_results(2 downto 0) & '0');

  -- 2nd cycle
  xor_results(11 downto 8) <= (gen_poly xor (xor_results(6 downto 4) & '0')) when xor_results(7) = '1' else (xor_results(6 downto 4) & '0');

  -- 3rd cycle
  xor_results(15 downto 12) <= (gen_poly xor (xor_results(10 downto 8) & '0')) when xor_results(11) = '1' else (xor_results(10 downto 8) & '0');

  -- 4th cycle
  xor_results(19 downto 16) <= (gen_poly xor (xor_results(14 downto 12) & '0')) when xor_results(15) = '1' else (xor_results(14 downto 12) & '0');
  
  output_crc <= xor_results(19 downto 16);

end architecture behavioral;
