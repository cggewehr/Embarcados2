library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.IO_pkg.all;
use ieee.std_logic_textio.all;
use std.textio.all;

-- Controle Module for a simple UART device
entity UART_control is
	generic (nUART 	: integer := 8); -- word size from/to UART
	port
	(
		-- interrupt flag
		uart_intr	: out std_logic;
	 	-- serial connections
		RxD			: in std_logic;							-- received data
		TxD			: out std_logic;						-- send data
		-- others signals
		clk			: in std_logic;
		rst			: in std_logic;
		we			: in std_logic;							-- write enable
		cs_UART_ctrl: in std_logic;							-- enable UART control/status register
		cs_UART_data: in std_logic;							-- enable UART data register
		cs_UART_bd	: in std_logic;							-- enable UART baudrate register
		data_in		: in std_logic_vector(nUART-1 downto 0);-- input data
		data_out	: out std_logic_vector(nUART-1 downto 0)-- output data
	);
	end entity UART_control;

architecture behavior of UART_control is

	COMPONENT UART
		generic(n_bits : positive := 16);
		port
		( -- transmissor ports
			UART_Tx_data_in  : in  std_logic_vector(7 downto 0);
			UART_Tx_data_out : out std_logic;
			UART_Tx_ready    : out std_logic;
			UART_Tx_write    : in  std_logic;
			-- receptor ports
			UART_RX_data_in  : in  std_logic;
			UART_RX_data_out : out std_logic_vector(7 downto 0);
			UART_RX_new_data : out std_logic;
			UART_RX_read     : in  std_logic;
			-- UART clock, system clock and reset
			divisor          : in  std_logic_vector((n_bits-1) downto 0);
			clk              : in  std_logic;
			rst              : in  std_logic
		  );
	end COMPONENT UART;

	signal UART_Tx_data_in	: std_logic_vector(nUART-1 downto 0);
	signal UART_RX_data_out	: std_logic_vector(nUART-1 downto 0);

	signal UART_write    : std_logic;
	signal UART_read     : std_logic;

	------------------
	-- UART Ctrl/Status Register
	constant two_zero	:	std_logic_vector(1 downto 0) := "00";
	signal	ctrl_reg	:	std_logic_vector(nUART-1 downto 0) := (others => '0');
	-- bits [7|3:2] are not used, and hardwired to 0
	-- bits [1:0] are controlled by the hardware and can only be read
	-- higher part
	alias	ctrl_reg_h	:	std_logic_vector(nUART-1 downto 4) is ctrl_reg(nUART-1 downto 4);
	alias	ITREN		:	std_logic	is	ctrl_reg(6);	-- uart read/write data interrupt enable, when enabled it will disabled the others interrupts
	alias	ITEN		:	std_logic	is	ctrl_reg(5);	-- uart write data interrupt enable
	alias	IREN		:	std_logic	is	ctrl_reg(4);	-- uart read data interrupt enable
	-- lower part
	alias	ctrl_reg_l	:	std_logic_vector(3 downto 0)		is ctrl_reg(3 downto 0);
	signal	TX_R		:	std_logic;		-- '1' means the uart is done sending the previous
	signal	RX_R		:	std_logic;		-- '1' means the uart is done receiving the previous data

	------------------
	-- UART Baudrate Register
	signal	baud_reg	:	std_logic_vector(nUART-1 downto 0) := x"04";	-- initial value: bd = 19171 (~19200)
	signal	divisor		:	std_logic_vector(15 downto 0);
	signal	divisor_i	:	integer range 0 to 5208;

	------------------
	-- Interrupt Flags
	signal	intr_t	:	std_logic;
	signal	intr_r	:	std_logic;
	signal	intr_tr	:	std_logic;

begin
----------------------------------
----- Data output
-- if trying to read the data register without valid data, it will be selected the
-- baudrate register
	data_out <= ctrl_reg		 when	(cs_UART_ctrl = '0')else
				UART_Rx_data_out when	(UART_read = '1')	else
				baud_reg;	--		 when	(cs_UART_bd = '0')

------------------------------------------------------------------------
------------------------------------------------------------------------
----------- Control/Status Register

	------- high part: bits [7:4]
	ctrl_reg_h(7) <= two_zero(1);

	CONTROL_UART: process (clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				ctrl_reg_h(6 downto 4)	<=	(others => '0');

			elsif (we = '1' AND cs_UART_ctrl = '0') then
				
				ctrl_reg_h(6 downto 4)	<=	data_in(6 downto 4);

			end if;
		end if;
	end process CONTROL_UART;

	------- lower part: bits [3:0]
	ctrl_reg_l	<=	two_zero & TX_R & RX_R;

	------- Interrupt logic
	intr_tr		<=	ITREN AND intr_t AND intr_r;
	intr_t		<=	ITEN AND TX_R;
	intr_r		<=	IREN AND RX_R;
	uart_intr	<=	((intr_t OR intr_r) AND (NOT(ITREN))) OR intr_tr;

------------------------------------------------------------------------
------------------------------------------------------------------------
----------- Data Register
	-- Read data only if ready
	UART_read	<= '1' when (cs_UART_data = '0' AND we = '0' AND RX_R = '1') else '0';

	-- Write data only if ready
	UART_write	<= '1' when (cs_UART_data = '0' AND we = '1' AND TX_R = '1') else '0';

	UART_Tx_data_in <=	data_in(nUART-1 downto 0) when (UART_write = '1') else
						(others => '0');

------------------------------------------------------------------------
------------------------------------------------------------------------
----------- IGNORED BY SYNTHESIS
	-- synthesis translate_off

	-- sim_uart_tx: process(clk)
	-- 	file file_handler	: text open write_mode is "/home/kevinm/sim_uart_tx";
	-- 	variable row		: line;
	-- begin
	-- 	if (rising_edge(clk)) then
	-- 		if (UART_write = '1') then
	-- 			hwrite(row, data_in, right, 1);
	-- 			writeline(file_handler , row);
	-- 		end if;
	-- 	end if;
	-- end process sim_uart_tx;

	-- sim_uart_rx: process(RX_R)
	-- 	file file_handler	: text open write_mode is "/home/kevinm/sim_uart_rx";
	-- 	variable row		: line;
	-- begin
	-- 	if (rising_edge(RX_R)) then
	-- 		hwrite(row, UART_Rx_data_out, right, 1);
	-- 		writeline(file_handler , row);
	-- 	end if;
	-- end process sim_uart_rx;

	-- synthesis translate_on
------------------------------------------------------------------------
------------------------------------------------------------------------
----------- Baudrate Register
	process (clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				baud_reg <= x"07";	-- initial value: bd = 19171 (~19200)
			
			elsif (cs_UART_bd = '0' AND we = '1') then
				baud_reg <= data_in;

			end if;
		end if;
	end process;

	-- baud_rate = clk / (16 * (divisor + 1)
	-- divisor = (clk / (16 * baud_rate) ) - 1
	with baud_reg(2 downto 0) select
		divisor_i <=5207	when	"000",	-- ~1200,07 bd
					2603	when	"001",	-- ~2400,1	bd
					1301	when	"010",	-- ~4800,3	bd
					650		when	"011",	-- ~9600,6 bd
					324		when	"100",	-- ~19230,7 bd
					161		when	"101",	-- ~38580,2 bd
					108		when	"110",	-- ~57339,4 bd
					53		when	others;	-- ~115740,7 bd
					-- 1		when	others;	-- faster simulation

	divisor <= std_logic_vector(to_unsigned(divisor_i , divisor'length));

--------------------------------------------------------------------------
	-- uart instance
	uart_i:	UART port map
	(
		clk				=> clk ,
		rst				=> rst ,
		divisor			=> divisor ,
		-- serial data
		UART_Tx_data_out=> TxD ,
		UART_Rx_data_in	=> RxD ,
		-- input and output 8 bits data
		UART_Tx_data_in	=> UART_Tx_data_in ,
		UART_Rx_data_out=> UART_Rx_data_out ,
		-- control flags
		UART_Tx_write	=> UART_write ,
		UART_Rx_read	=> UART_read ,
		UART_Tx_ready	=> TX_R ,
		UART_Rx_new_data=> RX_R
	);

end architecture behavior;
