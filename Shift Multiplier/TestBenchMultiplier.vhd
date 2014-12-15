
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity test_bench is
end entity test_bench;
architecture test_multiplier of test_bench is


		signal clk: std_logic := '0';
		signal reset :  bit := '0';
		signal multiplicand, multiplier :  bit_vector(3 downto 0):="0000";
		signal product :  bit_vector(7 downto 0) ; 
begin
dut : entity work.multiplier(mixed)
port map ( clk, reset ,multiplicand, multiplier ,product );
clk_process :process
   begin
        clk <= '0';
        wait for 200 ns/2;  
        clk <= '1';
        wait for 200 ns/2;  
   end process;

stimulus : process is
begin
multiplicand <= "0101"; multiplier <= "0101"; 
reset <= '0';
wait for 100 ns;



wait;
end process stimulus;
end architecture test_multiplier;