library ieee;
use ieee.std_logic_1164.all;

entity SquareRoot is
    
    port (

        -- Basic 
        Clock : in std_logic;
        Reset : in std_logic;

        -- Input value
        Input : in std_logic_vector(15 downto 0); -- Reset is used as DataAV

        -- Square root of input value
        SqrtOfInput : out out std_logic_vector(7 downto 0);
        Done : out std_logic

    );

end entity SquareRoot;

architecture RTL of SquareRoot is

    type state_t is (Sreset, Smult, Sxor, Sor, Sdone);
    signal currentState, nextState : state_t;

    signal c, g : std_logic_vector(7 downto 0);
    signal n, mult : std_logic_vector(15 downto 0);

begin

    process(Reset) begin

        if Reset = '1' then

            currentState <= Sreset;

        else

            currentState <= nextState;

        end if;

    end process;

    process(Clock) begin

        if rising_edge(Clock) then

            if currentState = Sreset then

                c <= (6 => '1', others <= 0);
                g <= (6 => '1', others <= 0);
                n <= Input;
                Done <= '0';

                nextState <= Smult;

            elsif currentState = Smult then

                mult <= g * g;

                if (g * g) > n then

                    nextState <= Sxor;

                else

                    nextState <= Sor;

                end if;

            elsif currentState = Sxor then

                g <= (g xor c) or (shift_right(unsigned(c), 1);
                c <= shift_right(unsigned(c), 1);

                if c == 1 then

                    nextState <= Smult;

                else

                    nextState <= Sdone;

                end if;

            elsif currentState = Sor then

                g <= g of (shift_right(unsigned(c), 1);
                c <= shift_right(unsigned(c), 1);

                if c == 1 then

                    nextState <= Smult;

                else

                    nextState <= Sdone;

                end if;

            elsif currentState = Sdone then

                Done <= '1';

                nextState <= Sdone;

            end if;

        end if;

    end process;
    
end architecture RTL;