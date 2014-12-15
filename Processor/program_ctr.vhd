library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--
-- Program Counter entity provides address to the Instruction Memory block for next instruction
entity program_ctr is
	generic (	ADDR_WIDTH  : integer := 8);
	port (	mem_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
			pc : in std_logic_vector(ADDR_WIDTH-1 downto 0);
			branch_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
			branch: in std_logic_vector(1 downto 0);
			int_en: in std_logic_vector(1 downto 0);
			clk, reset,reg_bk : in std_logic);
end entity program_ctr;

architecture behav of program_ctr is
begin
	cnt: process (clk, branch, reset,int_en)
		variable vpc,pc_addr, pc_addr_plus : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
	begin
		if reset = '1' then
			pc_addr := (others => '0');
			pc_addr_plus := (others => '0');
			
		elsif rising_edge(clk) then
			mem_addr <= pc_addr;
			pc_addr_plus := pc_addr + 1;	-- Increment PC on rising_edge
			
		elsif falling_edge(clk) then
		
			--branch case statement			
			CASE (branch) IS
				WHEN "00" =>
					pc_addr := pc_addr_plus;	--	No branch
				WHEN "01" =>
					pc_addr := branch_addr;		-- Branch immediate
				WHEN "10"=>
					pc_addr := pc_addr_plus-X"02"+branch_addr;	-- JZ
				WHEN "11"=>
					pc_addr := pc_addr_plus-X"02"+branch_addr;	-- JNZ
				when others=> null;
			end case;
			
			-- Branch to ISR
			CASE (int_en) IS
				
				WHEN "01" =>
					pc_addr := branch_addr;		-- Branch to ISR
				
				WHEN "11"=>
					pc_addr := branch_addr;		-- Return from ISR
				when others=> null;
			end case;
			
			
			
		end if;
		
	end process cnt;
end architecture behav;