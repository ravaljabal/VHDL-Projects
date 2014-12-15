library ieee;
use ieee.std_logic_1164.all;

package mem is
	type imem is array (0 to 2**8-1) of std_logic_vector(16-1 downto 0);
	type d_mem is array (0 to 2**8-1) of std_logic_vector(8-1 downto 0);
end package mem;
