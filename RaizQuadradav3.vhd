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
        SqrtOfInput : out std_logic_vector(7 downto 0);
        Done : out std_logic

    );

end entity SquareRoot;

architecture Structutal of SquareRoot is

    -- C
    signal c_Enable : std_logic;
    signal c_DataIn : std_logic_vector(7 downto 0);
    signal c_DataOut : std_logic_vector(7 downto 0);

    -- G
    signal g_Enable : std_logic;
    signal g_DataIn : std_logic_vector(7 downto 0);
    signal g_DataOut : std_logic_vector(7 downto 0);

    -- N
    signal n_Enable : std_logic;
    signal n_DataIn : std_logic_vector(15 downto 0);
    signal n_DataOut : std_logic_vector(15 downto 0);

    -- MULTIPLIER
    signal g_Squared : std_logic_vector(15 downto 0);

    -- COMPARATOR
    signal gSquaredGreaterThanN : std_logic;

    -- MUX
    signal g_xor : std_logic_vector(7 downto 0);
    signal g_or : std_logic_vector(7 downto 0);

begin

    ControlPath: block

        type state_t is (Sreset, Smult, Sxor, Sor, Sdone);
        signal currentState: state_t;

    begin

        NextStateLogic: process(Reset, Clock) begin

            if rising_edge(Clock) then

                if Reset = '1' then

                    currentState <= Sreset;

                elsif currentState = Sreset then

                    currentState <= Smult;

                elsif currentState = Smult then

                    if gSquaredGreaterThanN = '1' then

                        currentState <= Sxor;

                    else

                        currentState <= Sor;

                    end if;

                elsif currentState = Sxor then

                    if c_DataOut = 1 then

                        currentState <= Sdone;

                    else 

                        currentState <= Smult;

                    end if;

                elsif currentState = Sor then

                    if c_DataOut = 1 then

                        currentState <= Sdone;

                    else 

                        currentState <= Smult;

                    end if;

                elsif currentState = Sdone then

                    currentState <= Sdone;

                end if;

            end if;

        end process;

        OutputLogic: process(currentState) begin

            -- Default Values
            c_Enable <= '0';
            g_Enable <= '0';
            n_Enable <= '0';
            Done <= '0';

            if currentState = Sreset then

                n_Enable <= '1';

            elsif currentState = Smult then

                null;

            elsif currentState = Sxor then

                g_Enable <= '1';
                c_Enable <= '1';

            elsif currentState = Sor then

                g_Enable <= '1';
                c_Enable <= '1';

            elsif currentState = Sdone then

                Done <= '1';

            end if;

        end process;
        
    end block ControlPath;

    DataPath: block begin

        c_DataIn <= shift_right(unsigned(c_DataOut), 1);

        C: work.Register(SyncReset)
            generic map (
                DATAWIDTH => 8,
                RESETVALUE => 128, --(7 => '1', others <= 0);
                RESETLEVEL => '1'
            )
            port map (
                Clock => Clock,
                Reset => Reset,

                Enable => c_Enable,

                DataIn => c_DataIn,
                DataOut => c_DataOut
            );

        SqrtOfInput <= g_DataOut;

        G: work.Register(SyncReset)
            generic map (
                DATAWIDTH => 8,
                RESETVALUE => 128, --(7 => '1', others <= 0);
                RESETLEVEL => '1'
            )
            port map (
                Clock => Clock,
                Reset => Reset,

                Enable => g_Enable,

                DataIn => g_DataIn,
                DataOut => g_DataOut                
            );

        n_DataIn <= Input;

        N: work.Register(NoReset)
            generic map (
                DATAWIDTH => 16,
                RESETVALUE => 0, -- Not Used
                RESETLEVEL => '1' -- Not Used
            )
            port map (
                Clock => Clock,
                Reset => Reset,

                Enable => n_Enable,

                DataIn => n_DataIn,
                DataOut => n_DataOut
            );

        MULTIPLIER: work.Multiplier
            port map (
                A => g_DataOut,
                B => g_DataOut,
                MULT_OUT => g_Squared
            );

        COMPARATOR: gSquaredGreaterThanN <= '1' when g_Squared > n_DataOut else '0';

        g_xor <= (g_DataOut xor c_DataOut) or shift_right(unsigned(c_DataOut), 1);
        g_or <= g_DataOut or shift_right(unsigned(c_DataOut), 1);

        G_MUX: work.mux_2_1
            generic map (
                DATA_WIDTH => 8
            )
            port map (
                A0 => g_xor,
                A1 => g_or,
                s0 => mux_sel,
                result => g_DataIn
            );
        
    end block DataPath;

    
end architecture Structutal;

architecture Behavioural of SquareRoot is

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

                c <= (7 => '1', others <= 0);
                g <= (7 => '1', others <= 0);
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

                g <= (g xor c) or shift_right(unsigned(c), 1);
                c <= shift_right(unsigned(c), 1);

                if c == 1 then

                    nextState <= Smult;

                else

                    nextState <= Sdone;

                end if;

            elsif currentState = Sor then

                g <= g or shift_right(unsigned(c), 1);
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
    
end architecture Behavioural;