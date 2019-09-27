library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity SquareRootv2Estrutural is
    
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

end entity SquareRootv2Estrutural;

architecture Structural of SquareRootv2Estrutural is

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
    signal mux_sel : std_logic;

begin

    ControlPath: block

        type state_t is (Sreset, Siterate, Sdone);
        signal currentState: state_t;

    begin

        NextStateLogic: process(Reset, Clock) begin

            if rising_edge(Clock) then

                if Reset = '1' then

                    currentState <= Sreset;

                elsif currentState = Sreset then

                    currentState <= Siterate;

                elsif currentState = Siterate then

                    if cFlag = '1' then

                        currentState <= Sdone;

                    else

                        currentState <= Siterate;

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

            elsif currentState = Siterate then

                g_Enable <= '1';
                c_Enable <= '1';

                if cFlag = '1' then
                	Done <= '1';
                end if;

            elsif currentState = Sdone then

                Done <= '1';

            end if;

        end process;
        
    end block ControlPath;

    DataPath: block begin

        c_DataIn <= std_logic_vector(shift_right(unsigned(c_DataOut), 1));
        cFlag <= '1' when c = 0 else '0';

        C: entity work.ParametrizeableRegister(SyncReset)
            generic map (
                DATAWIDTH => 8,
                RESETVALUE => 128, --(7 => '1', others => '0');
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

        G: entity work.ParametrizeableRegister(SyncReset)
            generic map (
                DATAWIDTH => 8,
                RESETVALUE => 128, --(7 => '1', others => '0');
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

        N: entity work.ParametrizeableRegister(NoReset)
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

        MULTIPLIER: entity work.Multiplier
            port map (
                A => g_DataOut,
                B => g_DataOut,
                MUL_OUT => g_Squared
            );

        COMPARATOR: gSquaredGreaterThanN <= '1' when g_Squared > n_DataOut else '0';

        g_xor <= (g_DataOut xor c_DataOut) or (std_logic_vector(shift_right(unsigned(c_DataOut), 1)));
        g_or <= g_DataOut or (std_logic_vector(shift_right(unsigned(c_DataOut), 1)));

        mux_sel <= gSquaredGreaterThanN;

        G_MUX: entity work.mux_2_1
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
    
end architecture SquareRootv2Estrutural;
