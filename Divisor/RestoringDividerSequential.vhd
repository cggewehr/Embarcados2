--------------------------------------------------------------------------------
-- Company: Universidade Federal de Santa Maria
-- Engineers: Carlos Gabriel de Araujo Gewehr & Julio Costella Vicenzi
-- Create Date: 10/10/2019
-- Design Name: Signed Sequential Divider

-- Description:
--    A sequential implementation of the Restoring Division algorithm, as to calculate quotient and remainder in a division operation in "DataWidth" clock cycles
-- Dependencies:
--    None
-- Revision:
--    v0.1 - Initial version
-- Additional Comments:
--    
--------------------------------------------------------------------------------
library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.std_logic_signed.all;
    --use IEEE.numeric_std.all;

entity RestoringDividerSequential is

	generic (
	   DataWidth : natural := 32
	);
	port( 
	   Clock: in std_logic;
	   DataAV: in std_logic;
	   Done: out std_logic;
	   Divisor: in std_logic_vector(DataWidth - 1 downto 0);
	   Dividend: in std_logic_vector(DataWidth - 1 downto 0);
	   Quotient: out std_logic_vector(DataWidth - 1 downto 0);
	   Remainder: out std_logic_vector(DataWidth - 1 downto 0);
	   DivisionByZeroFlag: out std_logic
	);

end RestoringDividerSequential;

architecture Behavioral of RestoringDividerSequential is
    
begin

    process(Clock)
    
        variable DVDReg, DVSReg, QUOReg, REMReg, PreSubtractionTemp: std_logic_vector(DataWidth - 1 downto 0);
        variable ComplementAtEnd : std_logic;
        variable IterationCounter : natural range 0 to DataWidth - 1;
        variable DoneSave : std_logic;
    
    begin
    
        if rising_edge(Clock) then
        
            if DataAV = '1' then
            
                IterationCounter := 0;
                Done <= '0';
                DoneSave := '0';
                
                -- Sets Dividend effective value
                if Dividend(DataWidth - 1) = '0' then
                    DVDReg := Dividend;
                else
                    DVDReg := (not Dividend) + 1;
                end if;
                
                -- Sets Divisor effective value
                if Divisor(DataWidth - 1) = '0' then
                    DVSReg := Divisor;
                else
                    DVSReg := (not Divisor) + 1;
                end if;
                
                -- Sets division by zero flag (invalid operation)
                if Divisor = 0 then
                    DivisionByZeroFlag <= '1';
                else 
                    DivisionByZeroFlag <= '0';
                end if;
                
                -- Determines result sign (if its negative, Quotient will receive QUOReg's 2s Complement at the final iteraction)
                ComplementAtEnd := Dividend(DataWidth - 1) xor Divisor(DataWidth - 1);
                
                -- Initializes Quotient register
                QUOReg := (others => '0');
                
                PreSubtractionTemp := (0 => DVDReg(DataWidth - 1), others => '0');
                
                -- Executes algorithm iteraction
                if (PreSubtractionTemp - DVSReg) < 0 then
                    QUOReg(DataWidth - 1) := '0';
                    REMReg := PreSubtractionTemp;
                else
                    QUOReg(DataWidth - 1) := '1';
                    REMReg := PreSubtractionTemp - DVSReg;
                end if;
                
            else
            
                if IterationCounter /= DataWidth - 1 and DVSReg /= 0 then 
                    IterationCounter := IterationCounter + 1;
                end if;
                
                -- Shifts to the left and appends symmetrical dividend bit
                PreSubtractionTemp := (REMReg(DataWidth - 2 downto 0) & DVDReg(DataWidth - 1 - IterationCounter) );
                
                -- Executes algorithm iteraction
                if (PreSubtractionTemp - DVSReg) < 0 then
                    QUOReg(DataWidth - 1 - IterationCounter) := '0';
                    REMReg := PreSubtractionTemp;
                else
                    QUOReg(DataWidth - 1 - IterationCounter) := '1';
                    REMReg := PreSubtractionTemp - DVSReg;
                end if;
                
                if IterationCounter = DataWidth - 1 and DoneSave = '0' then
                
                    Remainder <= REMReg;
                    
                    Done <= '1';
                    DoneSave := '1';
                
                    if ComplementAtEnd = '1' then
                        Quotient <= (not QUOReg) + 1;
                    else
                        Quotient <= QUOReg;
                    end if;
                    
                end if;
            
            end if;
        
        end if;
    
    end process;

end Behavioral;
