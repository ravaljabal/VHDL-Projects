library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Decoder Stage of the pipeline
-- Instructions are decoded into ALUop,rdx,rdy 
-- Decision for jump are taken in this block
-- Interrupts are handeled in the decode section

entity decoder is
	generic ( 	INSTRUCTION_WIDTH : integer := 16;
				ADDRESS_WIDTH : integer := 4);
	port (	clk, init, zflag,in1 : in std_logic;
			int1 : in std_logic_vector(3 downto 0);
			branch_en,INT_EN : out std_logic_vector(1 downto 0);
			instruction : in std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
			ret_ext,exec,in_enable_ext,Ry_or_IM, Reg_or_I, ALU_or_Dmem, We, Re, pipe_off, Xhazard, Yhazard, push_nop : out std_logic;
			ALUop, sel : out std_logic_vector(3 downto 0);
			Rdx, Rdy, Wr : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
			Rls_addr, IM : out std_logic_vector(7 downto 0);
			spad_in:in std_logic_vector(7 downto 0);
			mem_addr:in std_logic_vector(7 downto 0);
 			spadout:out std_logic_vector(7 downto 0);
			PC:out std_logic_vector(7 downto 0);
			reg_address_ext:out std_logic_vector(4 downto 0);
			reg_bk_ext, reg_restr_ext: OUT std_logic);
end decoder; 

architecture behav of decoder is
	signal ALU_or_Dmem_temp : std_logic;
	signal in_enable,in_enable1,int_pending : std_logic;
	signal ret : std_logic;
	signal reg_bk, reg_restr,reg_bk_d, reg_restr_d  : std_logic;
	signal reg_address : std_logic_vector(4 downto 0);
	signal pc_temp : std_logic_vector(7 downto 0);
	signal int_mask: std_logic_vector(3 downto 0):="0000";
	signal intr_service:std_logic;
	signal int_jump : std_logic_vector(7 downto 0);
begin
	
	-- Map Interrupt handler and scratch pad
	IH_map: entity work.IH port map (clk => clk, init => init, in_enable => in_enable, in1 => in1, ret => ret,
				 reg_bk => reg_bk, reg_restr => reg_restr,reg_address=>reg_address, int_pending=>int_pending);
	spad_map: entity work.s_pad port map ( ret => ret,in_enable => in_enable, clk => clk,mem_addr=>mem_addr, reset => init,reg_bk => reg_bk, reg_restr => reg_restr,spad_in=>spad_in,reg_address=>reg_address,spadout=>spadout,PC=>pc_temp);

	
	func: process(clk,reg_bk,reg_restr,reg_bk_d) is
		variable vRdx, vRdy, vWr, Wr_old : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
		variable vexec,vRy_or_IM, vReg_or_I, vALU_or_Dmem, vWe, vRe, vALU_or_Dmem_temp, vXhazard, vYhazard : std_logic;
		variable vALUop, vsel: std_logic_vector(3 downto 0);
		variable vRls_addr, vIM : std_logic_vector(7 downto 0);
		variable checkRx, checkRy, vpush_nop,vin_enable,vin_enable1,vret : std_logic;
		variable vbranch_en : std_logic_vector(1 downto 0);
		variable vINT_en : std_logic_vector(1 downto 0):="00";
		
	begin
	
		-- Compute decoder outputs on falling_edge
		if falling_edge(clk) then	
			Wr_old := vWr;	
			vALUop := instruction(15 downto 12);
			vsel := instruction(11 downto 8);
			vRdx := instruction(7 downto 4);
			vRdy := instruction(3 downto 0);
			vWr := instruction(7 downto 4);
			vRy_or_IM := '0';
			vReg_or_I := '0';
			vALU_or_Dmem_temp := '0';
			vWe := '0';
			pipe_off <= '0';
			checkRx := '1';					-- Hazard check flags
			checkRy := '1';
			vRe := '1';
			vXhazard := '0';
			vYhazard := '0';
			vbranch_en := "00";
			vpush_nop := '0';				-- push nop on next instruction
			vin_enable1:='0';
			
			if init='1' then
				vin_enable:='0';
				vret:='0';
				vexec:='0';
			end if;
			case vALUop is
			--No Operation Inst
				when "0000" => 
					checkRx := '0';
					checkRy := '0';
					vRdx := (others => 'Z');
					vRdy := (others => 'Z');
					vWr := (others => 'Z');
			--INT Enable
				when "0111" => 
					vin_enable:='1';
					vret:='0';
					vALUop:="0000";
					int_mask<=instruction(3 downto 0);
			--RET INT
				when "1111" => 
					vin_enable1:='1';
					vret:='1';
					vpush_nop := '1';
					vexec:='0';
				
			--Add Immediate
				when "0001" => 
				
					vRy_or_IM := '1';
					vIM := instruction(7 downto 0);
					vRdx := instruction(11 downto 8);
					vWr := instruction(11 downto 8);
					vWe := '1';
					checkRy := '0';
					vret:='0';
		
			--Add/Sub Reg	
				when "0010" =>
					vWe := '1';
					vret:='0';
			
			--Inc/Dec		
				when "0011" =>
					vWe := '1';
					checkRy := '0';
					vret:='0';
				
			--Shift l/r	
				when "0100" =>
					--pipe_off <= '1';
					vWe := '1';
					vret:='0';
				
			--Logical	
				when "0101" => 
					if vsel = "1000" then
						vWr := instruction(3 downto 0);
					elsif (vsel = "0000") or (vsel = "0110") or (vsel = "0111") then
						checkRy := '0';
					end if;
					vWe := '1';
					vret:='0';
					
			
					
					
			--Load/store	
				when "1000" => 
					vReg_or_I := '1';
					vALU_or_Dmem_temp := '1';
					vWe := '1';
					vret:='0';
					
				when "1001" => 
					vReg_or_I := '1';
					vALU_or_Dmem_temp := '1';
					vRdx := instruction(3 downto 0);
					vRdy := instruction(7 downto 4);
					vret:='0';
					
				when "1010" => 
					vReg_or_I := '0';
					vRls_addr := instruction(7 downto 0);
					vRdx := instruction(11 downto 8);
					vWr := instruction(11 downto 8);
					vALU_or_Dmem_temp := '1';
					vWe := '1';
					checkRy := '0';
					vret:='0';

				when "1011" => 
					vReg_or_I := '0';
					vRls_addr := instruction(7 downto 0);
					vRdx := instruction(11 downto 8);
					vALU_or_Dmem_temp := '1';
					checkRy := '0';
					vret:='0';

			--Branch/Jump
				when "1100" => 
					vRy_or_IM := '1';
					vIM := instruction(7 downto 0);
					checkRx := '0';
					checkRy := '0';
					vbranch_en:="01";
					vpush_nop := '1';
					vret:='0';
					
				when "1101" => 
					vRy_or_IM := '1';
					vIM := instruction(7 downto 0);
					checkRx := '0';
					checkRy := '0';
					if zflag = '1' then
						vbranch_en:="10";
						vpush_nop := '1';
					end if;
					vret:='0';
				when "1110" => 
					vRy_or_IM := '1';
					vIM := instruction(7 downto 0);
					checkRx := '0';
					checkRy := '0';
					if zflag = '0' then
						vbranch_en:="11";	
						vpush_nop := '1';
					end if;
					vret:='0';
				
				
				when others => vret:='0';
			
			end case;
			
			-- Check for and handle data hazards
			if (((Wr_old = vRdx) and (checkRx = '1')) and (Wr_old /= "UUUU") and (Wr_old /= "ZZZZ")) then
				vXhazard := '1';
			
			elsif (((Wr_old = vRdy) and (checkRy = '1')) and (Wr_old /= "UUUU") and (Wr_old /= "ZZZZ")) then
				vYhazard := '1';
			end if;
			
			if in_enable='1' then
				vpush_nop:=reg_bk or reg_restr;				
			end if;

			INT_en <= vINT_en;
			branch_en <= vbranch_en;
			push_nop <= vpush_nop;
			
		end if;
		-- Interrupts jump selector
		if ((reg_restr)='0') then
			vINT_en:="00";		-- No jump using Interrupts
		end if;
		if ((reg_bk)='0') then
			vINT_en:="00";		-- No jump using Interrupts		
		end if;	
		-- Jump to ISR for interrupts
		if (falling_edge(reg_bk)) then
			vINT_en:="01";
			vIM := int_jump;
			vexec:='1';					
		end if;
		if (rising_edge(reg_restr)) then
			vexec:='0';					
		end if;
		-- Jump to back to pc+1 from ISR	
		if (falling_edge(reg_restr)) and int_pending/='1' then
			vINT_en:="11";
			vIM := pc_temp;
			vret:='0';							
		end if;
		-- Jump to back to pc+1 from ISR
		if (rising_edge(reg_restr)) and int_pending='1' then
			--vINT_en:="11";
			vIM := pc_temp;
			vret:='0';									
		end if;
		
		
		-- Update signals on rising_edge
		if rising_edge(clk) then
			Rdx <= vRdx;
			Rdy <= vRdy;
			Wr <= vWr;
			Ry_or_IM <= vRy_or_IM;
			Reg_or_I <= vReg_or_I;
			We <= vWe;
			Re <= vRe;
			ALU_or_Dmem_temp <= vALU_or_Dmem_temp;
			ALUop <= vALUop;
			sel <= vsel;
			Rls_addr <= vRls_addr;
			IM <= vIM;
			xhazard <= vXhazard;
			yhazard <= vYhazard;
			exec<=vexec;
			ret<=vret;
			
 			
			in_enable1<=vin_enable1;
			ret_ext<=vret;
		end if;
	end process;
	
	reg_address_ext<=reg_address;
			reg_bk_ext<=reg_bk;
			reg_restr_ext<=reg_restr;
	-- Latch the signal for Writeback stage
	l1: entity work.latch port map (clk => clk, in_bit => ALU_or_Dmem_temp, out_bit => ALU_or_Dmem, in_vect => "0000", out_vect => open);
	

	-- Handle Interrupt Priorities and check for interrupt enable
	sync_int: process(int1,int_mask,reg_restr,reg_bk_d,in_enable1) is
		variable  buffered_int: std_logic_vector(4-1 downto 0):="0000";
		variable  vin_enable,vreg_bk,vint_pending: std_logic:='0';
	begin
		buffered_int:=(int_mask and int1) or buffered_int;
		-- if restr complete reset in_enable 
		if (reg_restr'event and reg_restr='0')  then
			if vin_enable='1' then
				vin_enable:='0';
			end if;
		end if;
		
		-- if interrupts pending change in_enable and load ISR address
		if(buffered_int(3)='1') and vin_enable/='1' then
 			int_jump<="01100100";vin_enable:='1';buffered_int(3):='0';
			
		elsif buffered_int(2)='1' and vin_enable/='1'then
			int_jump <="01100101";vin_enable:='1';buffered_int(2):='0';
			
		elsif buffered_int(1)='1' and vin_enable/='1' then
			int_jump <="01100110";vin_enable:='1';buffered_int(1):='0';
			
		elsif buffered_int(0)='1' and vin_enable/='1' then
			int_jump <="01100111";vin_enable:='1';buffered_int(0):='0';
			
		else 
			in_enable<='0';
		end if;
		-- Check if any interrupts are pending.
		if(buffered_int(3 downto 0)/="0000") and vin_enable='1' then
 			vint_pending:='1';
		else 
			vint_pending:='0';
		end if;
		int_pending<=vint_pending;
		
		in_enable<=vin_enable;
		in_enable_ext<=vin_enable;
	end process;
		
end behav;	


