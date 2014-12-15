
Library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

use work.mem.d_mem;
-- data memory for the processor

entity dmem is
	generic ( DATA_WIDTH : integer := 8; ADDR_WIDTH : integer := 8);
	port (	clk, reset : in std_logic;
			memdin: in std_logic_vector(DATA_WIDTH-1 downto 0);
			memdout: out std_logic_vector(DATA_WIDTH-1 downto 0);
			ALUop: in std_logic_vector(3 downto 0);
			daddr:in std_logic_vector(ADDR_WIDTH-1 downto 0));
end dmem; 

architecture behav of dmem is  
  	shared variable data : d_mem;
begin
 process(clk, reset)
      begin
        if(reset = '1') then
         	data := (others => (others => '0'));  --reset everything to 0
        elsif (rising_edge(clk)) then
          	case (ALUop) IS
			when "1000" =>
				memdout <= data(to_integer(unsigned(daddr)));	-- load
			when "1001" =>
            	data(to_integer(unsigned(daddr))) := memdin;	-- store
			when "1010" =>
				memdout <= data(to_integer(unsigned(daddr)));	-- load
			when "1011" =>
            	data(to_integer(unsigned(daddr))) := memdin;	-- store
			when others => null;
            
			end case;          
       
        end if;
            
        end process;

end architecture behav;