-------------------------------------------------------------------------------
-- Title       : Parametrizable Register
-- Project     : 
-------------------------------------------------------------------------------
-- File        : 
-- Author      : Carlos Gabriel de Araujo Gewehr
-- Company     : 
-- Created     : 

-- Platform    : 
-- Standard    : 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity ParametrizeableRegister is

    generic (
        DATAWIDTH : integer := 32;
        RESETVALUE : integer := 0;
        RESETLEVEL : std_logic := '0'
    );

    port (
        Clock : in std_logic;
        Reset : in std_logic;

        Enable : in std_logic;

        DataIn : in std_logic_vector(DATAWIDTH - 1 downto 0);
        DataOut : out std_logic_vector(DATAWIDTH - 1 downto 0)

    );
    
end entity ParametrizeableRegister;

architecture SyncReset of ParametrizeableRegister is

begin

    process(Clock, Reset) begin

        if rising_edge(Clock) then

            if Reset = RESETLEVEL then

                DataOut <= std_logic_vector(to_unsigned(RESETVALUE, DataOut'length));

            elsif Enable = '1' then

                DataOut <= DataIn;

            end if;

        end if;

    end process;
    
end architecture SyncReset;

architecture ASyncReset of ParametrizeableRegister is

begin

    process(Clock, Reset) begin

        if Reset = RESETLEVEL then

            DataOut <= std_logic_vector(to_unsigned(RESETVALUE, DataOut'length));

        elsif rising_edge(Clock) then

            DataOut <= DataIn;

        end if;

    end process;
    
end architecture ASyncReset;

architecture NoReset of ParametrizeableRegister is

begin

    process(Clock) begin

        if rising_edge(Clock) and Enable = '1' then

            DataOut <= DataIn;

        end if;

    end process;
    
end architecture NoReset;