library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity FIFO_LOGIC is
  generic (N: integer := 3);
  port (CLK, PUSH, POP, INIT: in std_logic;
        ADD: out std_logic_vector(N-1 downto 0);
        FULL, EMPTY, WE, NOPUSH, NOPOP: buffer std_logic);
end entity FIFO_LOGIC;

architecture RTL of FIFO_LOGIC is
  signal WPTR, RPTR: std_logic_vector(N-1 downto 0);
  signal LASTOP: std_logic;
  
  begin
  
  SYNC: process (CLK)
  begin
    if (CLK'event and CLK = '1') then
      if (INIT = '1') then -- initialization --
        WPTR <= (others => '0');
        RPTR <= (others => '0');
        LASTOP <= '0';
      elsif (POP = '1' and EMPTY = '0') then -- pop --
        RPTR <= RPTR + 1;
        LASTOP <= '0';
      elsif (PUSH = '1' and FULL = '0') then -- push --
        WPTR <= WPTR + 1;
        LASTOP <= '1';
      end if; -- otherwise all Fs hold their value --
    end if;
  end process SYNC;
  
  COMB: process (PUSH, POP, WPTR, RPTR, LASTOP, FULL, EMPTY)
  begin
  -- full and empty flags --
    if (RPTR = WPTR) then
      if (LASTOP = '1') then
        FULL <= '1';
        EMPTY <= '0';
      else
        FULL <= '0';
        EMPTY <= '1';
      end if;
    else
      FULL <= '0';
      EMPTY <= '0';
    end if;
    
  -- address, write enable and nopush/nopop logic --
    if (POP = '0' and PUSH = '0') then -- no operation --
      ADD <= RPTR;
      WE <= '0';
      NOPUSH <= '0';
      NOPOP <= '0';
    elsif (POP = '0' and PUSH = '1') then -- push only --
      ADD <= WPTR;
      NOPOP <= '0';
      if (FULL = '0') then -- valid write condition --
        WE <= '1';
        NOPUSH <= '0';
      else -- no write condition --
        WE <= '0';
        NOPUSH <= '1';
      end if;
    elsif (POP = '1' and PUSH = '0') then -- pop only --
      ADD <= RPTR;
      NOPUSH <= '0';
      WE <= '0';
      if (EMPTY = '0') then -- valid read condition --
        NOPOP <= '0';
      else
        NOPOP <= '1'; -- no read condition --
      end if;
    else -- push and pop at same time ?
      if (EMPTY = '0') then -- valid pop --
        ADD <= RPTR;
        WE <= '0';
        NOPUSH <= '1';
        NOPOP <= '0';
      else
        ADD <= wptr;
        WE <= '1';
        NOPUSH <= '0';
        NOPOP <= '1';
      end if;
    end if;
  end process COMB;
end architecture RTL;
