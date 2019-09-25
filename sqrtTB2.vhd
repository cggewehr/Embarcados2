--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:59:14 09/09/2019
-- Design Name:   
-- Module Name:   /home/carlos/Desktop/Projetos ISE/IntegerSqrt/sqrtTB2.vhd
-- Project Name:  IntegerSqrt
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY sqrtTB2 IS
END sqrtTB2;
 
ARCHITECTURE behavior OF sqrtTB2 IS 

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
   UUT: entity work.SquareRoot PORT MAP (
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
      
		Reset <= '1';
		Input <= std_logic_vector(to_unsigned(25, Input'length));
      wait for 50 ns;
		Reset <= '0';
		wait for 950 ns;
		Reset <= '1';
		Input <= std_logic_vector(to_unsigned(29, Input'length));
      wait for 50 ns;
		Reset <= '0';
		wait for 950 ns;
		Reset <= '1';
		Input <= std_logic_vector(to_unsigned(49, Input'length));
      wait for 50 ns;
		Reset <= '0';
		wait for 950 ns;
		Reset <= '1';
		Input <= std_logic_vector(to_unsigned(50, Input'length));
      wait for 50 ns;
		Reset <= '0';
		wait for 950 ns;
		Reset <= '1';
		Input <= std_logic_vector(to_unsigned(81, Input'length));
      wait for 50 ns;
		Reset <= '0';
		wait for 950 ns;
		
      wait;
   end process;

END;
