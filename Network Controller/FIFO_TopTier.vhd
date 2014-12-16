library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity FIFO is
  generic ( N: integer := 3; -- number of address bits for 2**N address locations
            M: integer := 5); -- number of data bits to/from FIFO
  port (CLK, PUSH, POP, INIT: in std_logic;
        DIN: in std_logic_vector(M-1 downto 0);
        DOUT: out std_logic_vector(M-1 downto 0);
        FULL, EMPTY, NOPUSH, NOPOP: out std_logic);
end entity FIFO;

architecture TOP_HIER of FIFO is

  signal WE: std_logic;
  signal A: std_logic_vector(N-1 downto 0);

  component FIFO_LOGIC is
    generic (N: integer); -- number of address bits
    port (CLK, PUSH, POP, INIT: in std_logic;
          ADD: out std_logic_vector(N-1 downto 0);
          FULL, EMPTY, WE, NOPUSH, NOPOP: buffer std_logic);
  end component FIFO_LOGIC;
  
  component RAM is
    generic (K, W: integer); -- number of address and data bits
    port (WR: in std_logic; -- active high write enable
          ADDR: in std_logic_vector (W-1 downto 0); -- RAM address
          DIN: in std_logic_vector (K-1 downto 0); -- write data
          DOUT: out std_logic_vector (K-1 downto 0)); -- read data
  end component RAM;
  
  begin
    -- example of component instantiation using positional notation
    FL: FIFO_LOGIC generic map (N)
    port map (CLK, PUSH, POP, INIT, A, FULL, EMPTY, WE, NOPUSH, NOPOP);
    
    -- example of component instantiation using keyword notation
    R: RAM generic map (W => N, K => M)
    port map (DIN => DIN, ADDR => A, WR => WE, DOUT => DOUT);
    
end architecture TOP_HIER;
