library ieee;
use ieee.std_logic_1164.all;

entity mux is
	generic ( DWIDTH : integer := 8);
	port ( 	in1 : in std_logic_vector(DWIDTH-1 downto 0);
			in2 : in std_logic_vector(DWIDTH-1 downto 0);
			sel : in std_logic;
			muxout : out std_logic_vector(DWIDTH-1 downto 0));
end entity mux;

architecture behav of mux is
begin
	process (sel, in1, in2) is
	begin
		if (sel = '0') then
			muxout <= in1;
		elsif (sel = '1') then
			muxout <= in2;
		end if;
	end process;
end architecture behav;