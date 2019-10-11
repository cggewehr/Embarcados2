--------------------------------------------------------------------------------
-- Company: Universidade Federal de Santa Maria
-- Engineers: Carlos Gabriel de Araujo Gewehr & Julio Costella Vicenzi
-- Create Date: 10/10/2019
-- Design Name: Bit Calculator for Signed Combinational Divider
-- Description:
--    Instantiated by the Restoring Division algorithm implementation. Calculates a single digit of the quotient of a signed integer, and helps calculate the remainder of the whole division operation
-- Dependencies:
--    None
-- Revision:
--    v0.1 - Initial version
-- Additional Comments:
--    
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;

entity BitCalculator is
	generic (
	   DataWidth : natural := 16
	);
	port( 
	   DividendBit: in std_logic;
	   Divisor: in std_logic_vector(DataWidth - 1 downto 0);
	   AuxPrev: in std_logic_vector(DataWidth - 1 downto 0);
	   AuxNext: out std_logic_vector(DataWidth - 1 downto 0);
	   QuotientBit: out std_logic
	);
end BitCalculator;

architecture RTL of BitCalculator is

    signal subtractorTemp: std_logic_vector(DataWidth downto 0);
    signal auxPrevShifted: std_logic_vector(DataWidth - 1 downto 0);
    signal subtractorCarryOut : std_logic;

begin

    -- Shifts previous aux value to the left and appends DividendBit
    auxPrevShifted <= (AuxPrev(DataWidth - 2 downto 0) & DividendBit);
    
    -- Behaviourally executes auxPrevShifted - Divisor and determines carry out
    Subtractor: subtractorTemp <= ('0' & auxPrevShifted) - ('0' & Divisor);
    SubtractorCarry: subtractorCarryOut <= subtractorTemp(DataWidth);
    
    -- Determines AuxNext value
    AuxNextMux: AuxNext <= subtractorTemp(DataWidth - 1 downto 0) when subtractorCarryOut = '0' else
               auxPrevShifted;

    -- Determines QuotientBit
    QuotientBit <= not subtractorCarryOut;
    
end RTL;