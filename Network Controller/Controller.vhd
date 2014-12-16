library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity GatewayRouter is
	generic (N: integer := 8; -- number of address bits for 2**N address locations
	         M: integer := 64); -- number of data bits to/from FIFO
	port(	fifo_in1, fifo_in2, fifo_in3, fifo_in4 : in std_logic_vector(M-1 downto 0);
		fifo_out1, fifo_out2, fifo_out3, fifo_out4 : out std_logic_vector(M-1 downto 0);
		clk, init, push1, push2, push3, push4 : in std_logic;
		pop1, pop2, pop3, pop4 : in std_logic);
end entity GatewayRouter;

architecture behavioral of GatewayRouter is

	type routingtable is array(7 downto 0) of std_logic_vector(63 downto 0); -- 64 bits ( 16 bits - destination address, 
										-- 2 x 16 bits - 2 gateway addresses,
										-- status bits)

	signal rt : routingtable := (others => (others => '0'));

	signal full_in1, empty_in1, nopush_in1, nopop_in1 : std_logic;
	signal full_in2, empty_in2, nopush_in2, nopop_in2 : std_logic;
	signal full_in3, empty_in3, nopush_in3, nopop_in3 : std_logic;
	signal full_in4, empty_in4, nopush_in4, nopop_in4 : std_logic;
	signal full_out1, empty_out1, nopush_out1, nopop_out1 : std_logic;
	signal full_out2, empty_out2, nopush_out2, nopop_out2 : std_logic;
	signal full_out3, empty_out3, nopush_out3, nopop_out3 : std_logic;
	signal full_out4, empty_out4, nopush_out4, nopop_out4 : std_logic;

	signal addr1 : std_logic_vector(15 downto 0) := X"A111";
	signal addr2 : std_logic_vector(15 downto 0) := X"A112";
	signal addr3 : std_logic_vector(15 downto 0) := X"A113";
	signal addr4 : std_logic_vector(15 downto 0) := X"A114";

	type count_array is array(0 to 3) of integer;

	signal count : count_array := (others => 0);
	
	signal datain1, datain2, datain3, datain4 : std_logic_vector(M-1 downto 0); 	-- data popped fron incoming FIFOs
	signal dataout1, dataout2, dataout3, dataout4 : std_logic_vector(M-1 downto 0);	-- data to be pushed into outgoing FIFOs
	signal in_pop1, in_pop2, in_pop3, in_pop4 : std_logic := '0'; -- pop signals of incoming FIFOs
	signal out_push1, out_push2, out_push3, out_push4 : std_logic := '0'; -- push signals of outgoing FIFOs

	signal data : std_logic_vector(M-1 downto 0);

	component FIFO is
  		generic ( N: integer; -- := 3; -- number of address bits for 2**N address locations
		            M: integer); -- := 5); -- number of data bits to/from FIFO
		port (CLK, PUSH, POP, INIT: in std_logic;
			DIN: in std_logic_vector(M-1 downto 0);
		        DOUT: out std_logic_vector(M-1 downto 0);
		        FULL, EMPTY, NOPUSH, NOPOP: out std_logic);
	end component FIFO;

	signal gate_n : integer := 0;

	type state_type is (next_packet, state0, state1, select_wait, select_wait2, gateway1, gateway2, gateway3, gateway4, 
				gateway1s2, gateway2s2, gateway3s2, gateway4s2);
	signal state : state_type;

	signal i : integer := 0;

begin

-------- routing table ---------------
rt(0) <= X"A401A111A1120000";
rt(1) <= X"A402A112A1130000";
rt(2) <= X"A402A11400000000";
rt(3) <= X"A403A11300000000";
rt(4) <= X"A404A114A1110000";
rt(5) <= X"A405A111A1120000";
rt(6) <= X"A405A113A1140000";
rt(7) <= X"A406A114A1130000";
--------------------------------------

-------- Updating Status bits in Routing Table -----
rt(0)(15 downto 8) <= std_logic_vector(to_unsigned(count(0), 8));
rt(0)(7 downto 0) <= std_logic_vector(to_unsigned(count(1), 8));
rt(1)(15 downto 8) <= std_logic_vector(to_unsigned(count(1), 8));
rt(1)(7 downto 0) <= std_logic_vector(to_unsigned(count(2), 8));
rt(2)(15 downto 8) <= std_logic_vector(to_unsigned(count(3), 8));
rt(3)(15 downto 8) <= std_logic_vector(to_unsigned(count(2), 8));
rt(4)(15 downto 8) <= std_logic_vector(to_unsigned(count(1), 8));
rt(4)(7 downto 0) <= std_logic_vector(to_unsigned(count(0), 8));
rt(5)(15 downto 8) <= std_logic_vector(to_unsigned(count(0), 8));
rt(5)(7 downto 0) <= std_logic_vector(to_unsigned(count(0), 8));
rt(6)(15 downto 8) <= std_logic_vector(to_unsigned(count(0), 8));
rt(6)(7 downto 0) <= std_logic_vector(to_unsigned(count(0), 8));
rt(7)(15 downto 8) <= std_logic_vector(to_unsigned(count(0), 8));
----------------------------------------------------

state_proc : process(clk, state)
variable sel : integer := 0;
begin
if (clk'event and clk = '1') then

	if (init = '1') then
		state <= next_packet;
		count <= (others => 0);
	else
		if (pop1 = '1' and empty_out1 = '0') then 
			count(0) <= count(0) - 1;
		end if;
		if (pop2 = '1' and empty_out2 = '0') then 
			count(1) <= count(1) - 1;
		end if;
		if (pop3 = '1' and empty_out3 = '0') then 
			count(2) <= count(2) - 1;
		end if;
		if (pop4 = '1' and empty_out4 = '0') then 
			count(3) <= count(3) - 1;
		end if;

		case state is
	
		when next_packet =>

			case gate_n is
			
			when 0 =>
				if (empty_in1 = '0') then
					in_pop1 <= '1';
					state <= state0;
				else
					state <= next_packet;
				end if;
				gate_n <= gate_n + 1;

			when 1 =>
				if (empty_in2 = '0') then
					in_pop2 <= '1';
					state <= state0;
				else
					state <= next_packet;
				end if;
				gate_n <= gate_n + 1;

			when 2 =>
				if (empty_in3 = '0') then
					in_pop3 <= '1';
					state <= state0;
				else
					state <= next_packet;
				end if;
				gate_n <= gate_n + 1;

			when 3 =>
				if (empty_in4 = '0') then
					in_pop4 <= '1';
					state <= state0;
				else
					state <= next_packet;
				end if;
				gate_n <= 0;

			when others =>
				gate_n <= 0;

			end case;

		when state0 =>
			in_pop1 <= '0';
			in_pop2 <= '0';
			in_pop3 <= '0';
			in_pop4 <= '0';
			state <= state1;	
			
		when state1 =>
			if (gate_n = 1) then
				data <= datain1;
			elsif (gate_n = 2) then
				data <= datain2;
			elsif (gate_n = 3) then
				data <= datain3;
			elsif (gate_n = 0) then
				data <= datain4;
			end if;
			state <= select_wait;

		when select_wait =>
			if (i >= 0 and i < 8) then
				if (data(63 downto 48) = rt(i)(63 downto 48)) then
					if (addr1 = rt(i)(47 downto 32) or addr1 = rt(i)(31 downto 16)) then
						if (sel = 2 and count(1) <= count(0)) then
							sel := 2;
						elsif (sel = 3 and count(2) <= count(0)) then
							sel := 3;
						elsif (sel = 4 and count(3) <= count(0)) then
							sel := 4;
						else 
							sel := 1;
						end if;
					end if;				
					if (addr2 = rt(i)(47 downto 32) or addr2 = rt(i)(31 downto 16)) then
						if (sel = 1 and count(0) <= count(1)) then
							sel := 1;
				 		elsif (sel = 3 and count(2) <= count(1)) then
							sel := 3;
						elsif (sel = 4 and count(3) <= count(1)) then
							sel := 4;
						else 
							sel := 2;
						end if;
					end if;
					if (addr3 = rt(i)(47 downto 32) or addr3 = rt(i)(31 downto 16)) then
						if (sel = 1 and count(0) <= count(2)) then
							sel := 1;
						elsif (sel = 2 and count(1) <= count(2)) then
							sel := 2;
						elsif (sel = 4 and count(3) <= count(2)) then
							sel := 4;
						else 
							sel := 3;
						end if;
					end if;
					if (addr4 = rt(i)(47 downto 32) or addr4 = rt(i)(31 downto 16)) then
						if (sel = 1 and count(0) <= count(3)) then
							sel := 1;
						elsif (sel = 2 and count(1) <= count(3)) then
							sel := 2;
						elsif (sel = 3 and count(2) <= count(3)) then
							sel := 3;
						else 
							sel := 4;
						end if;
					end if;
				end if;

			end if;
			if (i = 7) then 
				i <= 0;
				state <= select_wait2;
			else
				state <= select_wait;
				i <= i + 1;
			end if;


		when select_wait2 =>

			if (sel = 1) then
				dataout1 <= data;
				state <= gateway1;
				sel := 0;
			elsif (sel = 2) then
				dataout2 <= data;
				state <= gateway2;
				sel := 0;
			elsif (sel = 3) then
				dataout3 <= data;
				state <= gateway3;
				sel := 0;
			elsif (sel = 4) then
				dataout4 <= data;
				state <= gateway4;
				sel := 0;
			else 
				state <= next_packet;
				sel := 0;
			end if;

		when gateway1 =>
			out_push1 <= '1';
			count(0) <= count(0) + 1;
			state <= gateway1s2;

		when gateway1s2 =>
			out_push1 <= '0';
			state <= next_packet;


		when gateway2 =>
			out_push2 <= '1';
			count(1) <= count(1) + 1;
			state <= gateway2s2;

		when gateway2s2 =>
			out_push2 <= '0';
			state <= next_packet;

		when gateway3 =>
			out_push3 <= '1';
			count(2) <= count(2) + 1;
			state <= gateway3s2;

		when gateway3s2 =>
			out_push3 <= '0';
			state <= next_packet;

		when gateway4 =>
			out_push4 <= '1';
			count(3) <= count(3) + 1;
			state <= gateway4s2;

		when gateway4s2 =>
			out_push4 <= '0';
			state <= next_packet;
		
		end case;
	end if;
end if;
end process state_proc;	



-------------------------------- bidirectional FIFO of Gateway 1 ----------------------------------

-- incoming FIFO of Gateway 1
fifo1_in : FIFO generic map ( N => N, M => M)
		port map ( CLK => clk,
			   PUSH => push1,
			   POP => in_pop1,
			   INIT => init,
			   DIN => fifo_in1,
			   DOUT => datain1,
			   FULL => full_in1,	-- gateway 1 incoming fifo full bit
			   EMPTY => empty_in1,	-- gateway 1 incoming fifo empty bit
			   NOPUSH => nopush_in1,	-- gateway 1 incoming fifo nopush bit
			   NOPOP => nopop_in1);	-- gateway 1 incoming fifo nopop bit

-- outgoing FIFO of Gateway 1
fifo1_out : FIFO generic map ( N => N, M => M)
		port map ( CLK => clk,
			   PUSH => out_push1,
			   POP => pop1,
			   INIT => init,
			   DIN => dataout1,
			   DOUT => fifo_out1,
			   FULL => full_out1,	-- gateway 1 outgoing fifo full bit
			   EMPTY => empty_out1,	-- gateway 1 outgoing fifo empty bit
			   NOPUSH => nopush_out1,	-- gateway 1 outgoing fifo nopush bit
			   NOPOP => nopop_out1);	-- gateway 1 outgoing fifo nopop bit

---------------------------------------------------------------------------------------------------

-------------------------------- bidirectional FIFO of Gateway 2 ----------------------------------

-- incoming FIFO of Gateway 2
fifo2_in : FIFO generic map ( N => N, M => M)
		port map ( CLK => clk,
			   PUSH => push2,
			   POP => in_pop2,
			   INIT => init,
			   DIN => fifo_in2,
			   DOUT => datain2,
			   FULL => full_in2,	-- gateway 2 incoming fifo full bit
			   EMPTY => empty_in2,	-- gateway 2 incoming fifo empty bit
			   NOPUSH => nopush_in2,	-- gateway 2 incoming fifo nopush bit
			   NOPOP => nopop_in2);	-- gateway 2 incoming fifo nopop bit

-- outgoing FIFO of Gateway 2
fifo2_out : FIFO generic map ( N => N, M => M)
		port map ( CLK => clk,
			   PUSH => out_push2,
			   POP => pop2,
			   INIT => init,
			   DIN => dataout2,
			   DOUT => fifo_out2,
			   FULL => full_out2,	-- gateway 2 outgoing fifo full bit
			   EMPTY => empty_out2,	-- gateway 2 outgoing fifo empty bit
			   NOPUSH => nopush_out2,	-- gateway 2 outgoing fifo nopush bit
			   NOPOP => nopop_out2);	-- gateway 2 outgoing fifo nopop bit

---------------------------------------------------------------------------------------------------

-------------------------------- bidirectional FIFO of Gateway 3 ----------------------------------

-- incoming FIFO of Gateway 3
fifo3_in : FIFO generic map ( N => N, M => M)
		port map ( CLK => clk,
			   PUSH => push3,
			   POP => in_pop3,
			   INIT => init,
			   DIN => fifo_in3,
			   DOUT => datain3,
			   FULL => full_in3,	-- gateway 3 incoming fifo full bit
			   EMPTY => empty_in3,	-- gateway 3 incoming fifo empty bit
			   NOPUSH => nopush_in3,	-- gateway 3 incoming fifo nopush bit
			   NOPOP => nopop_in3);	-- gateway 3 incoming fifo nopop bit

-- outgoing FIFO of Gateway 3
fifo3_out : FIFO generic map ( N => N, M => M)
		port map ( CLK => clk,
			   PUSH => out_push3,
			   POP => pop3,
			   INIT => init,
			   DIN => dataout3,
			   DOUT => fifo_out3,
			   FULL => full_out3,	-- gateway 3 outgoing fifo full bit
			   EMPTY => empty_out3,	-- gateway 3 outgoing fifo empty bit
			   NOPUSH => nopush_out3,	-- gateway 3 outgoing fifo nopush bit
			   NOPOP => nopop_out3);	-- gateway 3 outgoing fifo nopop bit


---------------------------------------------------------------------------------------------------

-------------------------------- bidirectional FIFO of Gateway 4 ----------------------------------

-- incoming FIFO of Gateway 4
fifo4_in : FIFO generic map ( N => N, M => M)
		port map ( CLK => clk,
			   PUSH => push4,
			   POP => in_pop4,
			   INIT => init,
			   DIN => fifo_in4,
			   DOUT => datain4,
			   FULL => full_in4,	-- gateway 4 incoming fifo full bit
			   EMPTY => empty_in4,	-- gateway 4 incoming fifo empty bit
			   NOPUSH => nopush_in4,	-- gateway 4 incoming fifo nopush bit
			   NOPOP => nopop_in4);	-- gateway 4 incoming fifo nopop bit

-- outgoing FIFO of Gateway 4
fifo4_out : FIFO generic map ( N => N, M => M)
		port map ( CLK => clk,
			   PUSH => out_push4,
			   POP => pop4,
			   INIT => init,
			   DIN => dataout4,
			   DOUT => fifo_out4,
			   FULL => full_out4,	-- gateway 4 outgoing fifo full bit
			   EMPTY => empty_out4,	-- gateway 4 outgoing fifo empty bit
			   NOPUSH => nopush_out4,	-- gateway 4 outgoing fifo nopush bit
			   NOPOP => nopop_out4);	-- gateway 4 outgoing fifo nopop bit

---------------------------------------------------------------------------------------------------

end architecture behavioral;