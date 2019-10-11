----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/11/2019 04:54:47 AM
-- Design Name: 
-- Module Name: DivisorTB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY sqrtTB2 IS
END sqrtTB2;
 
ARCHITECTURE testbench OF sqrtTB2 IS 

    -- Generics
    signal DataWidth : integer := 16;

    -- Inputs
    signal Dividend : std_logic_vector(DataWidth -1 downto 0) := (others => '0');
    signal Divisor : std_logic_vector(DataWidth -1 downto 0) := (others => '0');
   
    -- Outputs
    signal Quotient : std_logic_vector(DataWidth -1 downto 0);
    signal Remainder : std_logic_vector(DataWidth -1 downto 0);
    signal DivisionByZeroFlag : std_logic;

   -- Clock period definitions
   constant Clock_period : time := 10 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
    UUT: entity work.RestoringDivider 
    GENERIC MAP(
       DataWidth => 16
    )
    PORT MAP (
       Divisor => Divisor,
       Dividend => Dividend,
       Quotient => Quotient,
       Remainder => Remainder,
       DivisionByZeroFlag => DivisionByZeroFlag 
    );

    -- Stimulus process
    stim_proc: process begin		
      
        Dividend <= std_logic_vector(to_signed(10, Dividend'length));
        Divisor <= std_logic_vector(to_signed(2, Divisor'length));
        wait for 1 us;
        
        Dividend <= std_logic_vector(to_signed(100, Dividend'length));
        Divisor <= std_logic_vector(to_signed(20, Divisor'length));
        wait for 1 us;
        
        Dividend <= std_logic_vector(to_signed(10, Dividend'length));
        Divisor <= std_logic_vector(to_signed(0, Divisor'length));
        wait for 1 us;
        
        Dividend <= std_logic_vector(to_signed(128, Dividend'length));
        Divisor <= std_logic_vector(to_signed(64, Divisor'length));
        wait for 1 us;
        
        Dividend <= std_logic_vector(to_signed(129, Dividend'length));
        Divisor <= std_logic_vector(to_signed(64, Divisor'length));
        wait for 1 us;
        
        Dividend <= std_logic_vector(to_signed(5, Dividend'length));
        Divisor <= std_logic_vector(to_signed(2, Divisor'length));
        wait for 1 us;
        
        Dividend <= std_logic_vector(to_signed(-128, Dividend'length));
        Divisor <= std_logic_vector(to_signed(64, Divisor'length));
        wait for 1 us;
        
        Dividend <= std_logic_vector(to_signed(-128, Dividend'length));
        Divisor <= std_logic_vector(to_signed(-64, Divisor'length));
        wait for 1 us;
        
        Dividend <= std_logic_vector(to_signed(-129, Dividend'length));
        Divisor <= std_logic_vector(to_signed(-64, Divisor'length));
        wait for 1 us;
        
        
		
        wait;
    end process;

END testbench;