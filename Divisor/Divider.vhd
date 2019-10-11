--------------------------------------------------------------------------------
-- Company: Universidade Federal de Santa Maria
-- Engineers: Carlos Gabriel de Araujo Gewehr & Julio Costella Vicenzi
-- Create Date: 10/10/2019
-- Design Name: Signed Combinational Divider

-- Description:
--    A combinational implementation of the Restoring Division algorithm, as to calculate quotient and remainder in a division operation in a single clock cycle
-- Dependencies:
--    BitCalculator.vhd (Instantiated in the "QuotientBitCalculators" generate loop)
-- Revision:
--    v0.1 - Initial version
-- Additional Comments:
--    
--------------------------------------------------------------------------------
			
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;

entity RestoringDivider is
	generic (
	   DataWidth : natural := 16
	);
	port( 
	   Divisor: in std_logic_vector(DataWidth - 1 downto 0);
	   Dividend: in std_logic_vector(DataWidth - 1 downto 0);
	   Quotient: out std_logic_vector(DataWidth - 1 downto 0);
	   Remainder: out std_logic_vector(DataWidth - 1 downto 0);
	   DivisionByZeroFlag: out std_logic
	);
end RestoringDivider;

architecture RTL of RestoringDivider is

    component BitCalculator 
        generic(
            DataWidth: natural
        );
        port(
            DividendBit: in std_logic;
            Divisor: in std_logic_vector(DataWidth - 1 downto 0);
            AuxPrev: in std_logic_vector(DataWidth - 1 downto 0);
            AuxNext: out std_logic_vector(DataWidth - 1 downto 0);
            QuotientBit: out std_logic
        );
    end component;

    signal DivisorEffectiveValue, DividendEffectiveValue: std_logic_vector(DataWidth - 1 downto 0);
    signal QuotientTemporary : std_logic_vector(DataWidth - 1 downto 0);
    signal QuotientNegativeFlag : std_logic;
      
    type Auxes_t is array(0 to DataWidth) of std_logic_vector(DataWidth - 1 downto 0);
    signal Auxes: Auxes_t;

begin
    
    -- If value's MSB = 1, its a negative number, so, its 2s complement will be used as its effective value for operations performed by the algorithm
    DividendEffectiveValue <= Dividend when Dividend(DataWidth - 1) = '0' else (not Dividend) + 1;
    DivisorEffectiveValue <= Divisor when Divisor(DataWidth - 1) = '0' else (not Divisor) + 1 ;
    
    -- Generates "DataWidth - 1" Quotient Digit Calculators
    QuotientBitCalculators: for i in DataWidth - 1 downto 0 generate
    
        BitCalculators: BitCalculator 
            generic map(DataWidth => DataWidth)
            port map(
                DividendBit => DividendEffectiveValue(DataWidth - 1 - i),
                Divisor => DivisorEffectiveValue,
                AuxPrev => Auxes(i),
                AuxNext => Auxes(i + 1),
                QuotientBit => QuotientTemporary(DataWidth - 1 - i)               
            );
            
    end generate;
    
    -- Sets the AuxPrev bits for the first Digit Calculator
    Auxes(0) <= (others => '0');
        
    -- Defines the sign of the quotient by the MSB of the operands (same sign => positive, different sign => negative)
    QuotientNegativeFlag <= Divisor(DataWidth - 1) xor Dividend(DataWidth - 1);
    
    -- Defines Quotient final value, according to its sign (if its positive, take the value calculated by the bit calculator, if its negative, its 2s complement)
    Quotient <= QuotientTemporary when QuotientNegativeFlag = '0' else
                (not QuotientTemporary) + 1;
                
    -- Defines Remainder final value
    Remainder <= Auxes(DataWidth);
    
    -- Signals if divisor is = 0 (invalid operation)
    DivisionByZeroFlag <= '1' when Divisor = 0 else '0';

end RTL;