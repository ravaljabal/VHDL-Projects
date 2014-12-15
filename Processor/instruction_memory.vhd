library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.mem.imem;
--
-- Instruction Memory with preloaded Instructions
entity i_mem is
	generic (	ADDR_WIDTH : integer := 8;
				INSTRUCTION_WIDTH : integer := 16);
	port (	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);	-- Incoming PC value
			init,in_enable : in std_logic;
			push_nop,exec : in std_logic;
			reg_address: in std_logic_vector(4 downto 0);
			instruction : out std_logic_vector(INSTRUCTION_WIDTH-1 downto 0));
end entity i_mem;

architecture behav of i_mem is
	shared variable arr : imem;
begin

	initialize: process(init)
	begin
		if init = '1' then
			arr := (others => (others => '0'));
			
			arr(0) := "0101011000010000";	-- clear Rx(1)
			arr(1) := "0001000100000010";	-- Rx(1) += 02
			arr(2) := "0101011000100000";	-- clear Rx(2)
			arr(3) := "0001001010101011";	-- Rx(2) += ab
			arr(4) := "0101011000110000";	-- clear Rx(3)
			arr(5) := "0001001110101011";	-- Rx(3) += ab

			arr(6) := "0101011001000000";	-- clear Rx(4)
			arr(7) := "0001010010101011";	-- Rx(4) += ab
			arr(8) := "0101011001010000";	-- clear Rx(5)
			arr(9) := "0001010110101011";	-- Rx(5) += ab

			arr(10) := "0010000000100001";	-- add r2,r1
			
			arr(11) := "0100000000100001";	-- shiftl r2,r1
			arr(12) := "0101010000100001";	-- and r2,r1	
			arr(13) := "1001000000010011";	-- store r1,r3
			arr(14) := "1000000001100001";	-- load r6,r1

			arr(15) := "0111011000111111";	-- Int Enable
			
			arr(16) := "0101011010000000";	-- clear Rx(8)
			arr(17) := "0001100000000010";	-- Rx(8) += 02
			arr(18) := "0011000110000010";	-- Dec r8
			
			arr(19) := "1110011000000101";	-- jnz pc+5
			
						
			arr(20) := "0001001111001101";	-- Rx(3) = Rx + IM(BC)	AB+BC=78
			
			arr(21) := "0101011000010000";	-- clear Rx(1)
			arr(22) := "0001000100000010";	-- Rx(1) += 02
			arr(23) := "0101011000100000";	-- clear Rx(2)
			arr(24) := "0001001010101011";	-- Rx(2) += ab
			arr(25) := "0101011000110000";	-- clear Rx(3)
			arr(26) := "0001001110101011";	-- Rx(3) += ab

			arr(27) := "0101011001000000";	-- clear Rx(4)
			arr(28) := "0001010010101011";	-- Rx(4) += ab
			arr(29) := "0101011001010000";	-- clear Rx(5)
			arr(30) := "0001010110101011";	-- Rx(5) += ab

			arr(100) := "0001001111001101";	--Rx(3) = Rx + IM(BC)
			arr(101) := "0011000010000000";	--Rx(0) = Rx + 1	
			arr(102) := "0011000010000000";	--Rx(0) = Rx + 1	
			arr(103) := "0011000010000000";	--Rx(0) = Rx + 1	
			arr(104) := "1111000000000000";	--Rx(8) = Mem(Ry(0))
			
		end if;
	end process initialize;	

	-- Read Instruction memory and push nop for branch/Interrupt Instructions
	rd: process(addr,in_enable)
	begin
		if push_nop = '1' then
			instruction <= (others => '0');     	--Push NOP
		elsif (in_enable='1') then
			if(exec/='1') then
			instruction <= (others => '0');		--Push NOP
			else
			instruction <= arr(to_integer(unsigned(addr))); --Execute ISR
			end if;
		else
			instruction <= arr(to_integer(unsigned(addr)));	--Normal Execution	
			
		end if;
	end process rd;
	
end architecture behav;