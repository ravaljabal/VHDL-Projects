--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:40:34 11/06/2014
-- Design Name:   
-- Module Name:   E:/OneDrive/Documents/VHDL/Processor/pipelined_test.vhd
-- Project Name:  Processor
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: pipelined
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY pipelined_test IS
END pipelined_test;
 
ARCHITECTURE behavior OF pipelined_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pipelined
    PORT(
         clk : IN  std_logic;
         init : IN  std_logic;
	 in1 : IN  std_logic;
	 int1 : IN  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal init : std_logic := '0';
   signal in1 : std_logic := '0';
    signal int1 :std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 100 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pipelined PORT MAP (
          clk => clk,
          init => init,in1=>in1,int1=>int1
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      init <= '1';
      wait for 70 ns;	

      init <= '0';

      -- insert stimulus here 

      wait;
   end process;
   
   -- Give interrupts
   int_proc: process
   begin		
      int1 <= "0000";
      wait for 2400 ns;	

      int1 <= "1010";
      wait for 1000 ns;	
      int1 <= "0100";
      wait for 1000 ns;	
      int1 <= "0000";

      -- insert stimulus here 

      wait;
   end process;
END;
