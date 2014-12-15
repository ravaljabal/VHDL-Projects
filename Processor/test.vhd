library ieee;
use ieee.std_logic_1164.all;

entity test is
	port(o : out std_logic;
			clk : in std_logic);
end;

architecture argh of test is
	signal x : std_logic_vector(1 downto 0);
begin
	process(clk)
	begin
		if x="UU" then
			o <= '0';
		elsif x="11" then
			o <= 'W';
		else
			o <= '1';
		end if;
	end process;
end;
