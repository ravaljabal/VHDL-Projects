LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
-- Shift by 1 bit
ENTITY Shifter1 IS
	GENERIC (N : integer := 8);
	PORT (	Ain : IN std_logic_vector(N-1 downto 0);
		en,dir : IN std_logic;
		Aout : OUT std_logic_vector(N-1 downto 0));
			
END ENTITY Shifter1;
ARCHITECTURE behav OF Shifter1 IS
	
BEGIN

calc1: PROCESS (en)
begin
	if (en='1' and dir='0') then
		Aout<= Ain(N-2 downto 0) & '0';	--left shift
	elsif  (en='1' and dir='1') then
		Aout<= '0' & Ain(N-1 downto 1) ;	--right shift
	else
		Aout<=Ain;
	end if;
	end process;
end behav;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
-- Shift by 2 bit
ENTITY Shifter2 IS
	GENERIC (N : integer := 8);
	PORT (	Ain : IN std_logic_vector(N-1 downto 0);
		en,dir : IN std_logic;
		Aout : OUT std_logic_vector(N-1 downto 0));
			
END ENTITY Shifter2;
ARCHITECTURE behav OF Shifter2 IS
	
BEGIN

calc2: PROCESS (en,Ain)
begin
if (en='1' and dir='0') then
	Aout<= Ain(N-3 downto 0) & "00"; 	--left shift
elsif  (en='1' and dir='1') then
	Aout<= "00" & Ain(N-1 downto 2) ;		--right shift
else
	Aout<=Ain;
end if;
end process;
end behav;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
-- Shift by 3 bit
ENTITY Shifter3 IS
	GENERIC (N : integer := 8);
	PORT (	Ain : IN std_logic_vector(N-1 downto 0);
		en,dir : IN std_logic;
		Aout : OUT std_logic_vector(N-1 downto 0));
			
END ENTITY Shifter3;
ARCHITECTURE behav OF Shifter3 IS
	
BEGIN

calc3: PROCESS (en,Ain)
begin
if (en='1' and dir='0') then
	Aout<= Ain(N-5 downto 0) & "0000";	--left shift
elsif  (en='1' and dir='1') then
	Aout<= "0000" & Ain(N-1 downto 4) ;	--right shift
else
	Aout<=Ain;
end if;
end process;
end behav;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
-- top level entity for the shifter
ENTITY top_shift IS
	GENERIC (N : integer := 8);
	PORT (	Ain,Bin : IN std_logic_vector(N-1 downto 0);
		dir : IN std_logic;
		Aout : OUT std_logic_vector(N-1 downto 0));
			
END ENTITY top_shift;
ARCHITECTURE behav OF top_shift IS

signal aout1,aout2:std_logic_vector(N-1 downto 0);
BEGIN

shft1: entity work.shifter1 port map (Ain=>Ain,en=>Bin(0), dir => dir,Aout=>Aout1);
shft2: entity work.shifter2 port map (Ain=>Aout1, en=>Bin(1), dir => dir, Aout=>Aout2);
shft3: entity work.shifter3 port map (Ain=>Aout2, en=>Bin(2), dir => dir, Aout=>Aout);
	


end behav;