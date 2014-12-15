library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity shift_adder is
 
   port( addend: in bit_vector(7 downto 0);
 	 add_control: in bit;
	 CNT : in INTEGER;
	 clk2 : in std_logic;
	  --load :in bit;
	  sum: out bit_vector(7 downto 0);
         --load_control: out bit;
 	 augend: in bit_vector( 7 downto 0));
 
end shift_adder;
 
architecture behav of shift_adder is
signal some_vector: bit_vector(7 downto 0);
signal temp_vector: bit_vector(7 downto 0);
signal carry: bit_vector(7 downto 0);
--signal some_vector_s: std_logic_vector(7 downto 0):="00000000";
--signal augend_s: std_logic_vector(7 downto 0):="00000000";  
--signal t: integer := 0;   

begin
	
some_vector <= addend;

		carry(0)<='0';
		temp_vector(0) <= some_vector(0) xor augend(0) xor carry(0);
                carry(1) <= (some_vector(0) and augend(0)) or (carry(0) and augend(0)) or (some_vector(0) and carry(0));
                
                
                temp_vector(1) <= some_vector(1) xor augend(1) xor carry(1);
                carry(2) <= (some_vector(1) and augend(1)) or (carry(1) and augend(1)) or (some_vector(1) and carry(1));
                
                
                temp_vector(2) <= some_vector(2) xor augend(2) xor carry(2);
                carry(3) <= (some_vector(2) and augend(2)) or (carry(2) and augend(2)) or (some_vector(2) and carry(2));
                
                
                temp_vector(3) <= some_vector(3) xor augend(3) xor carry(3);
                carry(4) <= (some_vector(3) and augend(3)) or (carry(3) and augend(3)) or (some_vector(3) and carry(3));
                
                
                
                temp_vector(4) <= some_vector(4) xor augend(4) xor carry(4);
                carry(5) <= (some_vector(4) and augend(4)) or (carry(4) and augend(4)) or (some_vector(4) and carry(4));
                
                
                temp_vector(5) <= some_vector(5) xor augend(5) xor carry(5);
                carry(6) <= (some_vector(5) and augend(5)) or (carry(5) and augend(5)) or (some_vector(5) and carry(5));
                
                
                
                temp_vector(6) <= some_vector(6) xor augend(6) xor carry(6);
                carry(7) <= (some_vector(6) and augend(6)) or (carry(6) and augend(6)) or (some_vector(6) and carry(6));
                
                
                
                temp_vector(7) <= some_vector(7) xor augend(7) xor carry(7);
--		
--	     for i in 0 to 7 loop
--		case augend(i) is
--        		when '0' => augend_s(i) <= '0';
--        		when '1' => augend_s(i) <= '1';
--      		end case;
--		case some_vector(i) is
--        		when '0' => some_vector_s(i) <= '0';
--        		when '1' => some_vector_s(i) <= '1';
--      		end case;
--    	     end loop;
--
--             some_vector_s<=augend_s+some_vector_s;

--	     for i in 0 to 7 loop
--      		case some_vector_s(i) is
--        		WHEN '0' | 'L' => some_vector(i) <= '0';
--                	WHEN '1' | 'H' => some_vector(i) <= '1';
--                	WHEN OTHERS => some_vector(i) <= '1';
--      		end case;
--		
--    	     end loop;
	     
	      
	--end if;     
            
             
	
 sum <= temp_vector;    
	
   
end behav;