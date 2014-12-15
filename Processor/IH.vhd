library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
-- Interrupt Handler
entity IH is
	generic ( 	INSTRUCTION_WIDTH : integer := 16;
			ADDRESS_WIDTH : integer := 4);
	port (	clk, init, in_enable ,in1,ret : in std_logic;
		INT_PENDING : in std_logic;
		reg_bk,reg_restr : out std_logic;
		reg_address: inout std_logic_vector(4 downto 0));
end IH; 

architecture behav of IH is
	
begin
 cp : process (clk, in_enable ,in1,ret,init) is
 variable qnext : std_logic_vector ( 4 downto 0);
 variable temp : std_logic;
variable cnt_temp : std_logic;

 begin

if(init ='1') then
        cnt_temp:='0';
	qnext:="10011";
	
end if;
 -- Increase count(reg address) for return stage 
 if (RET= '1' and rising_edge(clk) ) then
	if int_pending='1' then
		if (qnext < "00001" ) then
		qnext := qnext +1;
		temp:='0';
		else
		qnext := "00000";
		temp:='1';
		end if;
	else

 		if (qnext < "10011" ) then
		qnext := qnext +1;
		temp:='1';
		else
		qnext := "10011";
		temp:='0';
		end if;
	end if;
 -- Decrease count(reg address) for return stage 
 elsif ( in_enable= '1' and rising_edge(clk) ) then
	if (qnext > "00000" ) then
		qnext := qnext -1;
		temp:='1';
	else
		qnext := "00000";
		temp:='0';
	end if;
 

  end if;
  -- set the reg_bk(backup) and reg_restr(restore) signals
  if (rising_edge(clk)) then
	if  ret='1' then
		reg_bk<='0';
		reg_restr<=temp;	
	
	elsif in_enable='1' and ret='0' then
		reg_bk<=temp;
		reg_restr<='0';
	elsif in_enable='0' and ret='0' then
		reg_bk<='0';
		reg_restr<='0';
	end if;
	reg_address <= qnext;
  end if;

end process cp;
end behav;
library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
-- Scratch pad for storing data for ISR 
ENTITY s_pad IS
	GENERIC	(ADDRESS_WIDTH	: integer := 4;
		 DATA_WIDTH	: integer := 8);
	PORT	(	in_enable,clk,reset	: IN std_logic;
			reg_bk, reg_restr,ret	: IN std_logic;
			spad_in			: IN  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
			reg_address		: IN  std_logic_vector(ADDRESS_WIDTH DOWNTO 0);
			PC			: OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
			mem_addr		:in std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
			spadout			: OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0)
		);
END s_pad;

architecture behav of s_pad is
	
	
begin
 process(clk,in_enable,reg_bk,reg_restr)
type bk_mem is array (0 to 2**4-1) of std_logic_vector(8-1 downto 0);
variable s_pad : bk_mem;
variable pc_bk:std_logic_vector(8-1 downto 0);
variable vreg_address :  std_logic_vector(ADDRESS_WIDTH DOWNTO 0);
      begin
		
        if(reset = '1') then
         	s_pad := (others => (others => '0'));
		
        elsif (falling_edge(clk)) then
			-- Copy data from the Reg bank to the scratch pad
          	if reg_address < "10000" and reg_bk='1' then
			s_pad(to_integer(unsigned(reg_address))) := spad_in;
       
        	elsif reg_address < "10000"and reg_restr='1' then
          	-- Copy data from the scratch pad to the reg bank
			spadout <= s_pad(to_integer(unsigned(reg_address)));
		elsif reg_restr'event and reg_restr='1' then
           		spadout <= s_pad(to_integer(unsigned(reg_address)));
		end if;
	end if;
	
	-- load value of backed up PC into a temp signal which goes to fetch block through decode block
	PC<=pc_bk ;
	-- backup the mem_addr into a pc_bk backup PC reg.

	if reg_address="10010" and reg_bk='1' then
		
			pc_bk:= mem_addr;

	end if;
	

            
        end process;

end architecture behav;
