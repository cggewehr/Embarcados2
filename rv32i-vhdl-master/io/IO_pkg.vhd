library ieee;
use ieee.std_logic_1164.all;

package IO_pkg is
-------------------------------------
---------- CONSTANTS
    constant n :        integer := 32;

-------------------------------------
---------- COMPONENTS
    COMPONENT UART_control
        generic(nUART   : integer := 8);
		port
		(
			clk			: in std_logic;
            rst		    : in std_logic;
			we  	    : in std_logic;
			uart_intr	: out std_logic;
			cs_UART_ctrl: in std_logic;
			cs_UART_data: in std_logic;
			cs_UART_bd	: in std_logic;
            RxD		    : in std_logic;
            TxD		    : out std_logic;
			data_in		: in std_logic_vector(nUART-1 downto 0);
			data_out	: out std_logic_vector(nUART-1 downto 0)
		);
    end COMPONENT UART_control;

    COMPONENT Timer0
		port
		(
			rst    : in std_logic;
            clk     : in std_logic;
            we      : in std_logic;
            cs_TIMER0: in std_logic;
            data_in : in std_logic_vector(n-1 downto 0);
			data_T0 : out std_logic_vector(n-1 downto 0)
		);
    END COMPONENT Timer0;

end package IO_pkg;
