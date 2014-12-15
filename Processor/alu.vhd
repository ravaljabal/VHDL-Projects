LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY alu IS
	GENERIC (N : integer := 8);
	PORT (	Ain, Bin : IN std_logic_vector(N-1 downto 0);
			opcode : IN std_logic_vector(3 downto 0);
			sel	: IN std_logic_vector(3 downto 0);
			ALUout : OUT std_logic_vector(N-1 downto 0);
			zflag : OUT std_logic;
			clk : IN std_logic);
END ENTITY alu;
-- Handles all logical, arithmetic operations
ARCHITECTURE behav OF alu IS
	SIGNAL shft_out : std_logic_vector(N-1 downto 0);
BEGIN
	calc: PROCESS (clk)
		variable x, y, z: std_logic_vector(N-1 downto 0) := "00000000";
	BEGIN
		IF falling_edge(clk) THEN
			x := Ain;
			y := Bin;
			CASE (opcode) IS
			WHEN "0001" =>
				z := x + y;	-- add immediate
			WHEN "0010" =>
				IF sel = "0000" THEN
					z := x + y;	-- add rx+ry
				ELSIF sel = "0001" THEN
					z := x - y;	-- sub rx-ry
				END IF;
			WHEN "0011" =>
				IF sel = "0000" THEN
					z := x + 1;	-- inc
				ELSIF sel = "0001" THEN
					z := x - 1;	-- dec
				END IF;
			WHEN "0100" =>
				z := shft_out;	-- shift
			WHEN "0101" =>		-- logical ops
				IF sel = "0000" THEN
					z := NOT x;	-- not 
				ELSIF sel = "0001" THEN
					z := x NOR y;	--nor
				ELSIF sel = "0010" THEN
					z := x NAND y; --nand
				ELSIF sel = "0011" THEN
					z := x XOR y;	--xor
				ELSIF sel = "0100" THEN
					z := x AND y;	--and
				ELSIF sel = "0101" THEN
					z := x OR y;	--or
				ELSIF sel = "0110" THEN
					z := (OTHERS => '0');	-- clear
				ELSIF sel = "0111" THEN
					z := (OTHERS => '1');	-- set
				ELSIF sel = "1111" THEN
					IF x < y THEN
						z := (OTHERS => '1');	-- set if rx<ry
					END IF;
				END IF;
				
			-- branch ops
			when "1100" => 
										
			when "1101" => 
				
			-- Return from Interrupts
			when "1110" => 
				
			when "1111" => null;
			WHEN OTHERS => NULL;
			END CASE;
			if (z = 0) then
				zflag <= '1';
			else 
				zflag <= '0';
			end if;
			
		END IF;
		if rising_edge(clk) then
			ALUout <= z;			
		end if;
	END PROCESS calc;

	-- Map shifter
	shft: entity work.top_shift port map (Ain => Ain, Bin => Bin, dir => sel(0), Aout => shft_out);

END ARCHITECTURE behav;

