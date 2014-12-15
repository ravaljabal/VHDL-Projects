LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-- reg bank entity
ENTITY reg_bank IS
	GENERIC	(	ADDRESS_WIDTH	: integer := 4;
				DATA_WIDTH	: integer := 8);
	PORT	(	init	,clk		: IN  std_logic;
				We, Re,in_enable,reg_bk,reg_restr,ret: IN std_logic;
				WrBk,spadout		: IN  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
				Rdx, Rdy, Wr: IN  std_logic_vector(ADDRESS_WIDTH - 1 DOWNTO 0);
				Rx, Ry ,spad_in		: OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
				reg_address:IN  std_logic_vector(ADDRESS_WIDTH DOWNTO 0);
				reg_change		: OUT std_logic);
END reg_bank;

ARCHITECTURE behav OF reg_bank IS
	TYPE RAM IS ARRAY(0 TO 2 ** ADDRESS_WIDTH - 1) OF std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);

	SIGNAL ram_block : RAM;
BEGIN
	-- Process to read from the registers
	PROCESS (Re, Rdx, Rdy)
		variable reg_set : std_logic := '0';
	BEGIN
		
		if Re = '1' then
			Rx <= ram_block(to_integer(unsigned(Rdx)));
			Ry <= ram_block(to_integer(unsigned(Rdy)));
		end if;
		
	END PROCESS;
	-- Process to read from the registers and back them up in scratch pad
	PROCESS ( reg_bk,reg_address)
		variable temp_reg:std_logic_vector (3 downto 0);
	BEGIN
			temp_reg:=reg_address(3 downto 0);
		 if ( reg_bk = '1' and reg_address<"10000") then
			spad_in<=ram_block(to_integer(unsigned(temp_reg)));
		 end if;
				
	END PROCESS;

	PROCESS (We, Wr, WrBk,reg_restr, spadout,clk)
	variable temp_reg1:std_logic_vector (7 downto 0);
	BEGIN
		if rising_edge(clk) then
			temp_reg1:=spadout;
		 end if;
		-- Process to writeback to the registers.
		IF (We = '1') THEN
			ram_block(to_integer(unsigned(Wr))) <= WrBk;
		
		ELSIF ( reg_restr = '1' and reg_address < "10000") then
		-- Process to write to the registers and restore them from scratch pad
			ram_block(to_integer(unsigned(reg_address(3 downto 0))))<=temp_reg1;
		 end if;
	END PROCESS;
			
END behav;
