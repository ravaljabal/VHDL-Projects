library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity GatewayRouter_TB is
end entity GatewayRouter_TB;

architecture behavioral of GatewayRouter_TB is

component GatewayRouter is
	generic (N: integer := 8; -- number of address bits for 2**N address locations
	         M: integer := 64); -- number of data bits to/from FIFO
	port(	fifo_in1, fifo_in2, fifo_in3, fifo_in4 : in std_logic_vector(M-1 downto 0);
		fifo_out1, fifo_out2, fifo_out3, fifo_out4 : out std_logic_vector(M-1 downto 0);
		clk, init, push1, push2, push3, push4 : in std_logic;
		pop1, pop2, pop3, pop4 : in std_logic);
end component GatewayRouter;

signal CLK, init : std_logic := '0';
signal N : integer := 8;
signal M : integer := 64;
signal fifo_in1, fifo_in2, fifo_in3, fifo_in4, fifo_out1, fifo_out2, fifo_out3, fifo_out4 : std_logic_vector(M-1 downto 0);
signal push1, push2, push3, push4, pop1, pop2, pop3, pop4 : std_logic;

begin

	CLK <= NOT CLK AFTER 10 NS;

	u2 : GatewayRouter generic map(N => N, M => M)
		port map(fifo_in1 => fifo_in1,
			fifo_in2 => fifo_in2,
			fifo_in3 => fifo_in3,
			fifo_in4 => fifo_in4,
			fifo_out1 => fifo_out1,
			fifo_out2 => fifo_out2,
			fifo_out3 => fifo_out3,
			fifo_out4 => fifo_out4,
			clk => CLK,
			init => init,
			push1 => push1,
			push2 => push2,
			push3 => push3,
			push4 => push4,
			pop1 => pop1,
			pop2 => pop2,
			pop3 => pop3,
			pop4 => pop4);

test : process
begin

-- Initialization
	INIT <= '1'; wait FOR 25 NS;
	INIT <= '0'; WAIT FOR 20 NS;

-- pushing data packets in incoming FIFOs
	fifo_in1 <= X"A401AAAAAAAAAAAA";
	push1 <= '1';	wait for 20 ns;

	push1 <= '0'; wait for 40 ns;

	fifo_in2 <= X"A403BBBBBBBBBBBB";
	push2 <= '1'; wait for 20 ns;

	push2 <= '0'; wait for 40 ns;
	
	fifo_in1 <= X"A404AB0A0A0A0AA0";
	push1 <= '1'; wait for 20 ns;

	push1 <= '0'; wait for 250 ns;
	
	fifo_in3 <= X"A405CCCCCCCCCCCC";
	push3 <= '1'; wait for 20 ns;
	push3 <= '0'; wait for 40 ns;

	fifo_in4 <= X"A402DDDDDDDDDDDD";
	push4 <= '1'; wait for 20 ns;
	
	push4 <= '0'; wait for 200 ns;

-- popping one packet from outgoing FIFO1
	pop1 <= '1'; wait for 20 ns;
	
	pop1 <= '0'; wait for 400 ns;

-- popping one packet from outgoing FIFO2
	pop2 <= '1'; wait for 20 ns;
	pop2 <= '0'; wait for 300 ns;

-- popping one packet from outgoing FIFO3 and 4 simultaneously 
	pop3 <= '1';
	pop4 <= '1'; wait for 60 ns;

	pop1 <= '0';
	pop2 <= '0';
	pop3 <= '0';
	pop4 <= '0'; wait for 60 ns;

-- pushing the data packets	
	fifo_in2 <= X"A40199AB29CD00BB"; wait for 20 ns;
	push2 <= '1'; wait for 20 ns;
	push2 <= '0'; wait for 100 ns;

	fifo_in1 <= X"A402A0A0A0A0A0A0"; wait for 20 ns;
	push2 <= '1'; wait for 20 ns;
	push2 <= '0'; wait for 100 ns;
	
	fifo_in3 <= X"A406999900990099"; wait for 20 ns;
	push2 <= '1'; wait for 20 ns;
	push2 <= '0'; wait for 100 ns;

	fifo_in2 <= X"A404123412341234"; wait for 20 ns;
	push2 <= '1'; wait for 20 ns;
	push2 <= '0'; wait for 100 ns;

	fifo_in4 <= X"A403ABABABCDCDCD"; wait for 20 ns;
	push2 <= '1'; wait for 20 ns;
	push2 <= '0'; wait for 100 ns;

	fifo_in1 <= X"A405AAAA0000CCCC"; wait for 20 ns;
	push2 <= '1'; wait for 20 ns;
	push2 <= '0'; wait for 100 ns;

	fifo_in4 <= X"A40599CDCDAAAACD"; wait for 20 ns;
	push2 <= '1'; wait for 20 ns;
	push2 <= '0'; wait for 100 ns;

	fifo_in1 <= X"A405111111111099"; wait for 20 ns;
	push2 <= '1'; wait for 20 ns;
	push2 <= '0'; wait for 1400 ns;

-- since the number of address bits are 8, number of memory locations in a FIFO are 256
-- to make a FIFO full, we need to push 256 data packets in single FIFO

-- we can test the conditions of full and empty FIFOs by making N smaller in Testbench

-- pop the data 
	
end process test;

end architecture behavioral;