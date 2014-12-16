
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity FIFO_TB is
end entity FIFO_TB;

architecture behavioral of FIFO_TB is

component FIFO is
  generic ( N: integer := 3; -- number of address bits for 2**N address locations
            M: integer := 5); -- number of data bits to/from FIFO
  port (CLK, PUSH, POP, INIT: in std_logic;
        DIN: in std_logic_vector(M-1 downto 0);
        DOUT: out std_logic_vector(M-1 downto 0);
        FULL, EMPTY, NOPUSH, NOPOP: out std_logic);
end component FIFO;

signal CLK : std_logic := '0';
signal PUSH, POP, INIT, FULL, EMPTY, NOPUSH, NOPOP : std_logic := '0';
signal N : integer := 3;
signal M : integer := 5;
signal DIN, DOUT : std_logic_vector(M-1 downto 0);

begin

	CLK <= NOT CLK AFTER 10 NS;

	u1: FIFO generic map(N => N, M => M)
		port map(CLK => CLK, PUSH => PUSH, POP => POP, INIT => INIT,
			 DIN => DIN, DOUT => DOUT, FULL => FULL,
			 EMPTY => EMPTY, NOPUSH => NOPUSH, NOPOP => NOPOP);

test : process
begin
	INIT <= '1'; wait FOR 25 NS;
	INIT <= '0'; WAIT FOR 20 NS;

	DIN <= "01011";
	PUSH <= '1'; WAIT FOR 20 NS;

	DIN <= "10101";
	PUSH <= '1'; WAIT FOR 20 NS;

	DIN <= "10011";
	PUSH <= '1'; WAIT FOR 20 NS;

	DIN <= "01011";
	PUSH <= '1'; WAIT FOR 20 NS;

	DIN <= "01001";
	PUSH <= '0'; WAIT FOR 20 NS;

	POP <= '1'; WAIT FOR 20 NS;

	POP <= '1'; WAIT FOR 20 NS;

	--POP <= '0';
	PUSH <= '1';
	POP <= '1'; WAIT FOR 20 NS;
	
	POP <= '0';
	DIN <= "10001";
	PUSH <= '1'; WAIT FOR 20 NS;

	DIN <= "01000";
	PUSH <= '1'; WAIT FOR 20 NS;

	DIN <= "11011";
	PUSH <= '1'; WAIT FOR 20 NS;

	DIN <= "11000";
	PUSH <= '1'; WAIT FOR 20 NS;

	DIN <= "10100";
	PUSH <= '1'; WAIT FOR 20 NS;

	DIN <= "01101";
	PUSH <= '1'; WAIT FOR 20 NS;

	DIN <= "01011";
	PUSH <= '1'; WAIT FOR 20 NS;

	DIN <= "01010";
	PUSH <= '1'; WAIT FOR 20 NS;
	
	PUSH <= '0';

	POP <= '1'; WAIT FOR 20 NS;
	POP <= '1'; WAIT FOR 180 NS;
	
	POP <= '0';
	DIN <= "11110";
	PUSH <= '1'; WAIT FOR 20 NS;

	PUSH <= '0';
	

end process test;

end architecture behavioral;