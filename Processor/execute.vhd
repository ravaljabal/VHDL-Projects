library ieee;
use ieee.std_logic_1164.all;

entity execute is
	generic (	ADDRESS_WIDTH	: integer := 4;
				DATA_WIDTH	: integer := 8);
	port (	Rdx, Rdy, Wr : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
			Ry_or_IM, Reg_or_I, We, Re, reset, Xhazard, Yhazard : in std_logic;
			ALU_or_Dmem : in std_logic;
			clk : in std_logic;
			IM : in std_logic_vector(DATA_WIDTH-1 downto 0);
			ALUop, sel : in std_logic_vector(3 downto 0);
			WrBk, Rls : in std_logic_vector(DATA_WIDTH-1 downto 0);
			execout : buffer std_logic_vector(DATA_WIDTH-1 downto 0);
			spad_in:Out std_logic_vector(7 downto 0);
 			spadout:in std_logic_vector(7 downto 0);
			reg_address:in std_logic_vector(4 downto 0);
			reg_bk, reg_restr,ret,in_enable: In std_logic;
			reg_change, zflag : out std_logic);
end entity execute;

architecture behav of execute is
	signal Rx, Rx_m, Ry, Ry_m, muxout, daddr : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal ALUout, memd : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
	-- reg bank	
	rb: entity work.reg_bank port map (clk=>clk,init => reset, We => We, Re => Re, WrBk => WrBk, Rdx => Rdx, Rdy => Rdy, Wr => Wr, Rx => Rx, Ry => Ry, reg_change => reg_change, in_enable => in_enable, ret => ret, reg_bk => reg_bk, reg_restr => reg_restr,spad_in=>spad_in,spadout=>spadout,reg_address=>reg_address);
	-- Select Im data or Ry reg data mux for alu
	mx1: entity work.mux port map (in1 => Ry_m, in2 => IM, sel => Ry_or_IM, muxout => muxout);
	-- Handle data hazard in the ALU
	mx2: entity work.mux port map (in1 => Rx, in2 => execout, sel => Xhazard, muxout => Rx_m);
	mx3: entity work.mux port map (in1 => Ry, in2 => execout, sel => Yhazard, muxout => Ry_m);
	-- ALU Operations
	al: entity work.alu port map (Ain => Rx_m, Bin => muxout, opcode => ALUop, sel => sel, ALUout => ALUout, clk => clk, zflag => zflag);
	-- Select Im data or Ry reg data mux for load/store  opeartions
	mx4: entity work.mux port map (in1 => Rls, in2 => Ry, sel => Reg_or_I, muxout => daddr);
	-- Data memory
	dm: entity work.dmem port map (clk => clk, reset => reset, memdin => Rx_m, memdout => memd, ALUop => ALUop, daddr => daddr);
	-- Select ALUout from alu and dmem
	mx5: entity work.mux port map (in1 => ALUout, in2 => memd, sel => ALU_or_Dmem, muxout => execout);

end architecture behav;