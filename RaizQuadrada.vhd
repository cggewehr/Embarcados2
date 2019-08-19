library ieee;
use ieee.std_logic_1164.all;

entity SquareRoot is
    
    port (

        -- Basic 
        Clock : in std_logic;
        Reset : in std_logic;

        -- Input value
        Input : in natural; -- Reset is used as DataAV

        -- Square root of input value
        SqrtOfInput : inout natural;
        Done : inout std_logic

    );

end entity SquareRoot;


-- 3 states per iteration, uses at least 2 adders
-- Separate next state and current state registers
-- One hot FSM encoding
-- Holds Done until next reset  when algorithm is finished
architecture Performance of SquareRoot is

    type State_t is (Sreset, SincRootSumTwo, Ssquare, Seval, Sdone);
    signal currentState, nextState : State_t;
    attribute fsm_encoding : string;
    attribute fsm_encoding of State_t : type is "one_hot"; -- Use "one-hot" if synthesizing with Quartus

    signal sumTwo, square, inputValue : natural;

begin

    NextStateRegister: process(Clock, Reset) begin

        if Reset = '1' then

            currentState <= Sreset;

        elsif rising_edge(Clock) then

            currentState <= nextState;

        end if;

    end process;

    OutputLogic: process(Clock) begin

        if rising_edge(Clock) then

            if currentState = Sreset then

                SqrtOfInput <= 1;
                sumTwo <= 2;
                square <= 4;

                inputValue <= Input;

                Done <= '0';
                SqrtOfInput <= 0;

                nextState <= SincRootSumTwo;

            elsif currentState = SincRootSumTwo then

                SqrtOfInput <= SqrtOfInput + 1;
                sumTwo <= sumTwo + 2;

                nextState <= Ssquare;

            elsif currentState = Ssquare then

                square <= square + sumTwo + 1;

                nextState <= Seval;

            elsif currentState = Seval then

                if ( inputValue - square ) > 0 then

                    nextState <= SincRootSumTwo;

                elsif ( inputValue - square ) = 0 then

                    SqrtOfInput <= SqrtOfInput + 1;

                    nextState <= Sdone;

                else 

                    nextState <= Sdone;

                end if;

            elsif currentState = Sdone then

                Done <= '1';

                nextState <= Sdone;

            end if;

        end if;

    end process;
    
end architecture Performance;


-- 4 states per iteration, can shared a single adder between all states
-- Only a current state register
-- Gray FSM encoding
-- Holds Done until next reset when algorithm is finished
architecture Area of SquareRoot is

    type State_t is (Sreset, SincRoot, SsumTwo, Ssquare, Seval, Sdone);
    signal currentState : State_t;
    attribute fsm_encoding : string;
    attribute fsm_encoding of State_t : type is "gray";

    signal sumTwo, square, inputValue : natural;

begin

    SingleStateRegisterFSM: process(Clock) begin

        if Reset = '1' then

            currentState <= Sreset;

        elsif rising_edge(Clock) then

            if currentState = Sreset then

                SqrtOfInput <= 1;
                sumTwo <= 2;
                square <= 4;

                inputValue <= Input;

                Done <= '0';
                SqrtOfInput <= 0;

                nextState <= SincRoot;

            elsif currentState = SincRoot then

                SqrtOfInput <= SqrtOfInput + 1;

                nextState <= Ssumtwo;

            elsif currentState = Ssumtwo then

                sumTwo <= sumTwo + 2;

                nextState <= Ssquare

            elsif currentState = Ssquare then

                square <= square + sumTwo + 1;

                nextState <= Seval;

            elsif currentState = Seval then

                if ( inputValue - square ) > 0 then

                    nextState <= SincRootSumTwo;

                elsif ( inputValue - square ) = 0 then

                    SqrtOfInput <= SqrtOfInput + 1;

                    nextState <= Sdone;

                else 

                    nextState <= Sdone;

                end if;

            end if;

        end if;

    end process;
    
end architecture Area;

-- 1 state per iteration
-- Only a current state register
-- Auto FSM encoding (to be determined by synthesizer)
-- Holds Done until next reset when algorithm is finished

architecture Behavioural of SquareRoot is

    type State_t is (Sreset, Siterate, Sdone);
    signal currentState : State_t;
    attribute fsm_encoding : string;
    attribute fsm_encoding of State_t : type is "auto";

begin

    process(clock, reset)

        variable root, sumTwo, square, inputValue, inputValue : natural;

    begin

        if reset = '1' then

            currentState <= Sreset;

        elsif rising_edge(clock) then

            if currentState = Sreset then

                root := 1;
                sumTwo := 2;
                square := 4;
                inputValue := Input;

                Done <= '0';

                nextState <= Siterate;

            elsif currentState = Siterate then

                root := root + 1;
                sumTwo := sumTwo + 2;
                square := square + sumTwo + 1;

                if ( inputValue - square ) > 0 then

                    currentState <= Siterate;

                elsif ( inputValue - square ) = 0 then

                    root := root + 1;
                    currentState <= Sdone;

                else

                    currentState <= Sdone;

                end if;

            elsif currentState = Sdone then

                SqrtOfInput <= root;
                Done <= '1';

                currentState <= Sdone;

            end if;

        end if;

    end process;
    
end architecture Behavioural;