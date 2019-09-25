library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.numeric_std.all;

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

architecture RTL of SquareRoot is

    type state_t is (Sreset, Smult, Sxor, Sor, Sdone);
    signal currentState : state_t;

begin

	process(Clock)

        variable c, g : std_logic_vector(7 downto 0);
    	variable n: std_logic_vector(15 downto 0);

    begin

        if rising_edge(Clock) then

        	if Reset = '1' then 

        		currentState <= Sreset;

        	else

	            if currentState = Sreset then

	                c := (7 => '1', others => '0');
	                g := (7 => '1', others => '0');
	                n := Input;
	                Done <= '0';

	                currentState <= Smult;

	            elsif currentState = Smult then

	                if (g * g) > n then

	                    currentState <= Sxor;

	                else

	                    currentState <= Sor;

	                end if;

	            elsif currentState = Sxor then

	                --g <= (g xor c) or (std_logic_vector(shift_right(unsigned(c), 1)));
	                --c <= std_logic_vector(shift_right(unsigned(c), 1));

	                g := g xor c;
	                c := std_logic_vector(shift_right(unsigned(c), 1));

	                if c = 0 then

	                    currentState <= Sdone;

	                else

	                	g := g or c;
	                    currentState <= Smult;

	                end if;

	            elsif currentState = Sor then

	                --g <= g or std_logic_vector(shift_right(unsigned(c), 1));
	                c := std_logic_vector(shift_right(unsigned(c), 1));

	                if c = 0 then

	                    currentState <= Sdone;

	                else

	                    g := g or c;
	                    currentState <= Smult;

	                end if;

	            elsif currentState = Sdone then

	                Done <= '1';
	                SqrtOfInput <= g;
	                currentState <= Sdone;

	            end if;

	        end if;

        end if;

    end process;
    
end architecture RTL;