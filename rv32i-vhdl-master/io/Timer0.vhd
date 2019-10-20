library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.IO_pkg.all;

entity Timer0 is
	port(	rst 	: in std_logic;
			clk     : in std_logic;
			we		: in std_logic;							-- write enable
			cs_TIMER0: in std_logic;						-- enable the timer when '0'
			data_in	: in std_logic_vector(n-1 downto 0);	-- input data
			data_T0 : out std_logic_vector(n-1 downto 0));	-- output of the timer
end entity Timer0;

architecture behavior of Timer0 is

	signal reg_T0  : std_logic_vector(n-1 downto 0);

begin
	data_T0 <= 	reg_T0;

	t0_count :  process(clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				reg_T0 <= (others => '0');

			elsif (we = '1' AND cs_TIMER0 = '0') then
				reg_T0 <= data_in;

			else
				reg_T0 <= std_logic_vector(unsigned(reg_T0) + 1);

			end if;
		end if;
	end process t0_count;

end architecture behavior;
