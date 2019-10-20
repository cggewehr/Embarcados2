library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- file io
use ieee.std_logic_textio.all;
use std.textio.all;

-- string <-> stdlogic_vec convert
use work.string_utils.all;

-- Controle Module for a simple UART device
entity top_module_uart is
	generic (nUART 	: integer := 8); -- word size from/to UART
	port
	(
	 	-- serial connections
		RxD			: in std_logic;		-- received data
		TxD			: out std_logic;	-- send data
		-- others signals
		clk			: in std_logic;
		rst			: in std_logic
	);
	end entity top_module_uart;

architecture behavior of top_module_uart is

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

	signal UART_write    : std_logic;
	signal UART_read     : std_logic;

	------------------
	-- UART Ctrl/Status Flags
	signal	TX_R		:	std_logic;		-- '1' means the uart is done sending the previous
	signal	RX_R		:	std_logic;		-- '1' means the uart is done receiving the previous data

	------------------
	-- UART Baudrate Register
	signal	baud_reg	:	std_logic_vector(nUART-1 downto 0) := x"07";	-- initial value: bd = 19171 (~19200)
	signal	divisor		:	std_logic_vector(15 downto 0);
	signal	divisor_i	:	integer range 0 to 5208;

	------------------
	-- File signals and I/O flags
	signal	en_TX	:	std_logic;
	signal	we		:	std_logic;

	signal	d_in	:	std_logic_vector(nUART-1 downto 0) := (others => '0');
	signal	d_out	:	std_logic_vector(nUART-1 downto 0) := (others => '0');

begin

------------------------------------------------------------------------
------------------------------------------------------------------------
-----------	File I/O
	-- save in a text file all data received from another serial device
	sim_uart_data_received: process(clk)
		file		file_RX	:	text open write_mode is "text_file/uart_sim/data_received.log";
		variable	row_RX	:	line;
		variable	d_char	:	character := '_';
	begin
		if (rising_edge(clk)) then
			-------------------------------
			if (UART_read = '1') then
				d_char := stdv_2_ascii(d_out);

				if (d_out = x"0A") then
					writeline(file_RX , row_RX);
				else
					write(row_RX , d_char , right, 1);
				end if;

			end if;
			-------------------------------
		end if;
	end process sim_uart_data_received;

	-- read a file with all data to be send to another serial device
	sim_uart_data_transmitted: process(clk)
		file		file_TX	:	text open read_mode is "text_file/uart_sim/data_transmitted.log";
		variable	row_TX	:	line;
		variable	d_char	:	character := '_';
		variable	no_line	:	std_logic := '1';
		variable	count	:	integer := 0;
		variable	count_up:	integer := 0;
		variable	last_line:	std_logic := '0';
		variable	last_hold:	std_logic := '0';
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				we		<= '0';
				no_line	:= '1';
				count	:= 0;
				count_up:= 0;
				last_line := '0';
				last_hold := '0';
			-------------------------------
			elsif (not endfile(file_TX) OR last_line = '1') then
				-------------------------------
				if (we = '0' AND TX_R = '1' AND en_TX = '1') then
					
					if (last_line = '1' AND last_hold = '1') then
						--- send a last new line (note: optional)
						d_in <= x"0A";
						last_line := '0';

					elsif (no_line = '1') then
						readline(file_TX , row_TX);
						no_line	:= '0';
						count	:= 0;
						count_up:= row_TX'LENGTH;

						-- send new line
						d_in <= x"0A";

					else
						read(row_TX , d_char);
						d_in <= ascii_2_stdv(d_char);

						-- end of line
						count := count + 1;
						if (count = count_up) then
							no_line := '1';
							if (last_line = '1') then
								last_hold := '1';
							end if;
						end if;

					end if;
					
					if (endfile(file_TX) AND last_hold = '0') then
						last_line := '1';
					end if;

					we <= '1';

				else
					we <= '0';
				end if;
			-------------------------------
			else
				we <= '0';
	 		-------------------------------			 
			end if;
	 		-------------------------------
		end if;
	end process sim_uart_data_transmitted;



	process
	begin
		en_TX <= '0';
		loop
			wait for 1400 us;
			en_TX <= '1';
			wait for 10 sec;
		end loop;
	end process;

------------------------------------------------------------------------
------------------------------------------------------------------------
----------- Data Register

	----------- Data Read/Write Flag	
	-- Read data only if ready
	UART_read	<= '1' when (RX_R = '1') else '0';

	-- Write data only if ready
	UART_write	<= '1' when (we = '1' AND TX_R = '1' AND en_TX = '1') else '0';

	----------- Baudrate Register
	process (clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				baud_reg <= x"07";	-- initial value: bd = 115200
			end if;
		end if;
	end process;

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
	top_module_sub_uart_i:	UART port map
	(
		clk				=> clk ,
		rst				=> rst ,
		divisor			=> divisor ,
		-- serial data
		UART_Tx_data_out=> TxD ,
		UART_Rx_data_in	=> RxD ,
		-- input and output 8 bits data
		UART_Tx_data_in	=> d_in ,
		UART_Rx_data_out=> d_out ,
		-- control flags
		UART_Tx_write	=> UART_write ,
		UART_Rx_read	=> UART_read ,
		UART_Tx_ready	=> TX_R ,
		UART_Rx_new_data=> RX_R
	);

end architecture behavior;
