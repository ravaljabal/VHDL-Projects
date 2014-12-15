library ieee;
use ieee.std_logic_1164.all;

entity shift_reg is
    port(
         clk : in std_logic;
	 load :in bit;
         d : in bit_vector(3 downto 0);
         q : out bit);
end shift_reg;

architecture behav of shift_reg is

    signal t : bit:='0';
    signal temp : bit_vector(3 downto 0):="0000";

begin

   process (clk,d,load)
    begin
       if (load='1') then
             temp(3 downto 0) <= d(3 downto 0);
       elsif (CLK'event and CLK='0') then
             q <= temp(0);
             temp <= "0" & temp(3 downto 1);
             
       end if;
    end process;



end behav;