library ieee;
use ieee.std_logic_1164.all;
-- Writeback stage of the pipeline
entity writeback is
	generic (	DATA_WIDTH	: integer := 8;
				ADDRESS_WIDTH : integer := 4);
	port (	clk : in std_logic;
			execout : in std_logic_vector(DATA_WIDTH-1 downto 0);
			WrBk : out std_logic_vector(DATA_WIDTH-1 downto 0);
			Wr_in: in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
			Wr_out : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
			We_in : in std_logic;
			We_out : out std_logic);
end entity writeback;

architecture mixed of writeback is
	signal We_temp : std_logic;
	signal Wr_temp : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
	signal muxout : std_logic_vector(DATA_WIDTH-1 downto 0);
begin

	-- delay signals using latches
	l1: entity work.latch port map (clk => clk, in_bit => We_in, out_bit => We_temp, in_vect => Wr_in, out_vect => Wr_temp);
	l2: entity work.latch port map (clk => clk, in_bit => We_temp, out_bit => We_out, in_vect => Wr_temp, out_vect => Wr_out);	
	l3: entity work.latch generic map (DATA_WIDTH => DATA_WIDTH) port map (clk => clk, in_bit => '0', out_bit => open, in_vect => execout, out_vect => WrBk);
	
end architecture mixed;