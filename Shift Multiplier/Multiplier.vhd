
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity multiplier is
	port ( clk: in std_logic;
		 reset : in bit;
		multiplicand, multiplier : in bit_vector(3 downto 0);
		product : out bit_vector(7 downto 0) );
end entity multiplier;

architecture mixed of multiplier is
	signal partial_product, full_product : bit_vector(7 downto 0);
	signal mult_bit : bit;
	signal mult_load : bit:='1';
	signal result_en,arith_control: bit;
	signal  cnt : integer:=0;
	signal temp_vector: bit_vector(7 downto 0);
	signal temp1_vector: bit_vector(7 downto 0);
	signal clk2 :std_logic:='0';
	
	
	begin
		arith_unit : entity work.shift_adder(behav)
		port map ( addend => temp_vector, augend => full_product,
			sum => partial_product,
			add_control => arith_control,clk2=>clk,CNT=>CNT
		 );
		result : entity work.reg(behav)
		port map ( d => partial_product, q => full_product,
			en => arith_control, reset => reset ,clk=>clk);
		multiplier_sr : entity work.shift_reg(behav)
		port map ( d =>multiplier , q => mult_bit,
			load => mult_load, clk => clk );
		multiplicand_sr :entity work.shift_reg1(behav)
		port map ( d =>multiplicand , q => temp_vector,
			load => mult_load, clk2 => clk,add_control => arith_control );
		product<=full_product;
	load_process :process
   	begin
        
        wait for 10 ns;  --for 0.5 ns signal is '0'.
        mult_load <= '0';
	--wait for 800 ns;  --for next 0.5 ns signal is '1'.
	--mult_load <= '1';
	
   	end process;
	
	clock1_process :process(clk)
   	begin
        if (falling_edge(clk)) then
		clk2<=not clk2;
	end if;
        
   	end process;
	
	control_section : process(clk, reset) is
	
	
	

	begin
		
	   
          if (clk'event and clk='1') then
	  CNT<=CNT+1;
      
        	arith_control <= mult_bit; 
           elsif (reset='1') then
		arith_control<='0';
      end if;

		
end process ;
end architecture mixed;


