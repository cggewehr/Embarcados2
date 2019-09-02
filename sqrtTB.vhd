--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:34:04 09/02/2019
-- Design Name:   
-- Module Name:   /home/carlos/Desktop/IntegerSquareRoot/sqrtTB.vhd
-- Project Name:  IntegerSquareRoot
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SquareRoot
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
use ieee.numeric_std.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY sqrtTB IS
END sqrtTB;
 
ARCHITECTURE behavior OF sqrtTB IS 

    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SquareRoot
    PORT(
         Clock : IN  std_logic;
         Reset : IN  std_logic;
         Input : IN  std_logic_vector(15 downto 0);
         SqrtOfInput : OUT  std_logic_vector(7 downto 0);
         Done : OUT  std_logic
        );
    END COMPONENT;

   --Inputs
   signal Clock : std_logic := '0';
   signal Reset : std_logic := '0';
   signal Input : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal SqrtOfInput : std_logic_vector(7 downto 0);
   signal Done : std_logic;

   -- Clock period definitions
   constant Clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SquareRoot PORT MAP (
          Clock => Clock,
          Reset => Reset,
          Input => Input,
          SqrtOfInput => SqrtOfInput,
          Done => Done
        );

   -- Clock process definitions
   Clock_process :process
   begin
		Clock <= '0';
		wait for Clock_period/2;
		Clock <= '1';
		wait for Clock_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 1000 ns.
		Input <= std_logic_vector(to_unsigned(25, Input'length));
		Reset <= '1';
      wait for 1000 ns;	
		Reset <= '0';
      -- hold reset state for 1000 ns.
		Input <= std_logic_vector(to_unsigned(49, Input'length));
		Reset <= '1';
      wait for 1000 ns;	
		Reset <= '0';      -- hold reset state for 1000 ns.
		Input <= std_logic_vector(to_unsigned(50, Input'length));
		Reset <= '1';
      wait for 1000 ns;	
		Reset <= '0';      -- hold reset state for 1000 ns.
		Input <= std_logic_vector(to_unsigned(81, Input'length));
		Reset <= '1';
      wait for 1000 ns;	
		Reset <= '0';
      wait;
   end process;

END;
