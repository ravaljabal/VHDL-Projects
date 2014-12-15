library ieee;
use ieee.std_logic_1164.all;

entity latch is
	generic ( DATA_WIDTH : integer := 4);
	port ( 	clk : in std_logic;
			in_bit : in std_logic;
			out_bit : out std_logic;
			in_vect : in std_logic_vector(DATA_WIDTH-1 downto 0);
			out_vect : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity latch;

architecture behav of latch is
begin
	process (clk) is
	begin
		if rising_edge(clk) then
			out_bit <= in_bit;
			out_vect <= in_vect;
		end if;
	end process;
end architecture behav;