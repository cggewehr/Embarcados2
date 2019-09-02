-------------------------------------------------------------------------------
-- Title       : Behavioural Modified Pyramid Multiplier
-- Project     : 
-------------------------------------------------------------------------------
-- File        : 
-- Author      : Vladimir V. Erokhin
-- Company     : 
-- Created     : 

-- Platform    : 
-- Standard    : 
-------------------------------------------------------------------------------
-- Description: Uses algorithm by V. Erokhin
-------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;    

library work;
    use mult_pyramid_mod.all;

entity Multiplier is
    generic (
        DATAWIDTH: integer := 8
    );
    port (
        CLK: in std_logic;
        A: in STD_LOGIC_VECTOR (DATAWIDTH - 1  downto 0);
        B: in STD_LOGIC_VECTOR (DATAWIDTH - 1 downto 0);
        MUL_OUT: out STD_LOGIC_VECTOR (DATAWIDTH * 2 - 1 downto 0)
    );
end Multiplier;

architecture Behavioural of MULT_UNIT is

begin

    MUL_OUT <= MULT_PYRAMID_MOD(A, B);
    
end architecture RTL;

