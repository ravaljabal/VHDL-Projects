library ieee;
use ieee.std_logic_1164.all;

entity fetch is
	generic ( 	INSTRUCTION_WIDTH : integer := 16;
				ADDR_WIDTH : integer := 8);
	port (	clk, init,reg_bk,in_enable,exec : in std_logic;
			branch: in std_logic_vector(1 downto 0);
			INT_EN: in std_logic_vector(1 downto 0);
			reg_address: in std_logic_vector(4 downto 0);
			branch_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
			mem_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
			push_nop : in std_logic;
			PC : inout std_logic_vector(ADDR_WIDTH-1 downto 0);
			instruction : out std_logic_vector(INSTRUCTION_WIDTH-1 downto 0));
end entity fetch;

architecture behav of fetch is
	signal mem_addr_1 : std_logic_vector(ADDR_WIDTH-1 downto 0);
begin
	mem_addr<=mem_addr_1;
	-- Program Counter entity provides address to the Instruction Memory block for next instruction
	pc1: entity work.program_ctr port map (mem_addr => mem_addr_1, branch_addr => branch_addr, clk => clk, 
						branch => branch, reset => init,PC=>PC,INT_EN=>INT_EN, reg_bk=>reg_bk);
	-- Instruction Memory with preloaded Instructions
	im: entity work.i_mem port map (addr => mem_addr_1, init => init, instruction => instruction, push_nop => push_nop,
					in_enable=>in_enable, reg_address=>reg_address,exec=>exec);
end architecture behav;