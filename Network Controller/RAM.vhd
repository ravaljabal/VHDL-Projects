
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity RAM is
    generic (K, W: integer); -- number of address and data bits
    port (WR: in std_logic; -- active high write enable
          ADDR: in std_logic_vector (W-1 downto 0); -- RAM address
          DIN: in std_logic_vector (K-1 downto 0); -- write data
          DOUT: out std_logic_vector (K-1 downto 0)); -- read data
end entity RAM;

architecture behavioral of RAM is
	type address is array(2**W-1 downto 0) of std_logic_vector(K-1 downto 0);
	signal ram_data : address := (others => (others => '0'));
	signal addr_int : integer;
begin
	addr_int <= to_integer(unsigned(ADDR));
	
	ram_data(addr_int) <= DIN when (ADDR'event and WR = '1');
	
	DOUT <= ram_data(addr_int) when (ADDR'event and WR = '0');
	
	
end architecture behavioral;
