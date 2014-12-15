library ieee;
use ieee.std_logic_1164.all;
-- Top level entity for the processor
entity pipelined is
	generic ( 	INSTRUCTION_WIDTH : integer := 16;
				IMEM_ADDR_WIDTH : integer := 8;
				DATA_WIDTH : integer := 8;
				ADDR_WIDTH:integer := 4);
	port (	clk, init,in1 : in std_logic;
			int1 : in std_logic_vector (3 downto 0));
end entity pipelined;

architecture mixed of pipelined is
	signal instruction : std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
	signal Rdx, Rdy, Wr_in, Wr : std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal Ry_or_IM, Reg_or_I, We_in, We, Re, ALU_or_Dmem ,exec: std_logic;
	signal Xhazard, Yhazard : std_logic;
	signal IM : std_logic_vector(7 downto 0);
	signal ALUop, sel : std_logic_vector(3 downto 0);
	signal Rls_Addr : std_logic_vector(7 downto 0);
	signal execout, WrBk : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal pipe_clk, pipe_off, reg_change, zflag, push_nop : std_logic;
	signal branch : std_logic_vector(1 downto 0) := "00";
	signal int_en : std_logic_vector(1 downto 0) := "00";
	signal in_enable : std_logic;
	signal ret : std_logic;
	signal pc:std_logic_vector(7 downto 0);
	signal reg_bk, reg_restr : std_logic;
	signal reg_address : std_logic_vector(4 downto 0);
	signal spad_in: std_logic_vector(7 downto 0);
 	signal spadout: std_logic_vector(7 downto 0);
	signal mem_addr: std_logic_vector(7 downto 0);
	
begin
	-- Fetch block 
	fetch: entity work.fetch port map (clk => clk, branch => branch, init => init, 
	push_nop => push_nop,  branch_addr => IM,mem_addr=>mem_addr,reg_bk=>reg_bk,
	in_enable=>in_enable, instruction => instruction,PC=>PC,int_en=>int_en,
	reg_address=>reg_address,exec=>exec);
	-- Decode block 
	decode: entity work.decoder port map (clk => clk, init => init,
		 instruction => instruction, branch_en => branch, push_nop => push_nop, zflag => zflag,
		 Ry_or_IM => Ry_or_IM, Reg_or_I => Reg_or_I, ALU_or_Dmem => ALU_or_Dmem, Wr => Wr_in,
	 ALUop => ALUop, sel => sel, Xhazard => Xhazard, Yhazard => Yhazard, Rdx => Rdx, Rdy => Rdy, 
	Rls_Addr => Rls_Addr, IM => IM, We => We_in, Re => Re, pipe_off => pipe_off, 
	in_enable_ext => in_enable, in1 => in1, ret_ext => ret, reg_bk_ext => reg_bk, 
	reg_restr_ext => reg_restr,spad_in=>spad_in,spadout=>spadout,PC=>PC,
	reg_address_ext=>reg_address,int_en=>int_en,mem_addr=>mem_addr,int1=>int1,exec=>exec);
	-- Execute block 
	execute: entity work.execute port map ( clk => clk, Rdx => Rdx, Rdy => Rdy, Wr => Wr,
	 Ry_or_IM => Ry_or_IM, Reg_or_I => Reg_or_I, We => We, Re => Re, reset => init, 
	ALU_or_Dmem => ALU_or_Dmem, Xhazard => Xhazard, Yhazard => Yhazard, IM => IM,
	 ALUop => ALUop, sel => sel, execout => execout, WrBk => WrBk, Rls => Rls_Addr,
	 reg_change => reg_change, zflag => zflag,in_enable => in_enable, ret=> ret,
	 reg_bk => reg_bk, reg_restr => reg_restr,spad_in=>spad_in,spadout=>spadout,reg_address=>reg_address);
	-- writeback block 
	writeback: entity work.writeback port map (clk => clk, execout => execout, WrBk => WrBk, 
	Wr_in => Wr_in, Wr_out => Wr, We_in => We_in, We_out => We);
	
	pclk: process(clk, pipe_off, reg_change) is
		variable pipe_state : std_logic := '1';
		variable ctr1 : integer := 0;
	begin
		if (pipe_off'event and ALUop /= "0100") then
			if (pipe_state = '1') and (pipe_off = '1') then
				pipe_state := '0';
				ctr1 := 2;
			end if;
		elsif (pipe_off'event and ALUop = "0100") then
			if (pipe_state = '1') and (pipe_off = '1') then
				pipe_state := '0';
				ctr1 := 8;
			end if;
		end if;
		if clk'event then
			if pipe_state = '1' then
				pipe_clk <= clk;
			else
				pipe_clk <= pipe_clk;
				if rising_edge(clk) then
					ctr1 := ctr1 - 1;
				end if;
				if ctr1 < 1 then
					pipe_state := '1';report "2";
					ctr1 := 0;
				end if;
			end if;
		end if;
	end process pclk;
	
end architecture mixed;