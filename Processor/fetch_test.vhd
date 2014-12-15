library ieee;
use ieee.std_logic_1164.all;

entity fetch_test is
	generic ( 	INSTRUCTION_WIDTH : integer := 16;
				ADDR_WIDTH : integer := 8);
end entity fetch_test;

architecture behav of fetch_test is
	component fetch is
		port (	clk, branch, init : in std_logic;
			branch_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
			instruction : out std_logic_vector(INSTRUCTION_WIDTH-1 downto 0));
	end component fetch;

	signal clk, branch, init : std_logic;
	signal branch_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal instruction : std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
	
	constant clk_period : time := 100 ns;
	
begin
	
	uut: fetch port map (clk, branch, init, branch_addr, instruction);
	
	clk_process: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process clk_process;
	
	stim_proc: process
	begin
		wait for 100 ns;
		init <= '0';
		branch <= '0';
		wait for clk_period;
		init <= '1';
		wait for clk_period;
		init <= '0';
		wait;
	end process;
end;