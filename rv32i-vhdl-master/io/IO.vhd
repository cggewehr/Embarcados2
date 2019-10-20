library ieee;
use ieee.std_logic_1164.all;
use work.IO_pkg.all;
use work.map_pkg.all;

-- Control the access to the devices: UART and Timer0.
entity IO is
	port
	(
		rst			: in std_logic;
		clk     	: in std_logic;
		io_intr		: out std_logic;
		valid_addr	: in std_logic;
        we      	: in std_logic;
        addr    	: in std_logic_vector(n-1 downto 0);
        data_io 	: inout std_logic_vector(n-1 downto 0);
        ---- received/transmitted bit through UART
        RxD     	: in std_logic;
		TxD     	: out std_logic
	);
end entity IO;

architecture behavior of IO is

	constant nUART	: integer := 8;

	-- interrupt signals
	signal uart_intr	:	std_logic;

	-- each device address enable signal
	signal cs_UART		: std_logic;
	signal cs_UART_ctrl	: std_logic;
	signal cs_UART_data	: std_logic;
	signal cs_UART_bd	: std_logic;
    signal cs_TIMER0   	: std_logic;

	signal data_in_UART	: std_logic_vector(nUART-1 downto 0);	-- uart input data (8 bits)
	signal data_out_UART: std_logic_vector(nUART-1 downto 0);	-- uart output data (8 bits)
    signal data_T0  	: std_logic_vector(n-1 downto 0);       -- timer0 input/output data (32 bits)
	signal addr_BUS 	: std_logic_vector(n-1 downto 0);		-- io data bus
	alias  addr_io		is addr_BUS(15 downto 0);

	-- address and io enable section flag
	constant	SEC_IO	:	std_logic_vector(15 downto 0) := IO_start(31 downto 16);
	alias		SEC_addr is	addr_BUS(n-1 downto 16);
	signal 		en_io	:	std_logic;

begin

------------------------------------------------
-- IO Interrupt Output
	io_intr	<=	uart_intr;

------------------------------------------------
-- IO section enable
	en_io	<=	'1' when (SEC_addr = SEC_IO) else
				'0';

------------------------------------------------
-- address bus, if the address is not valid, it will be set in a value
-- wich will not enable this section in the next cycle, to minimize the hardware
-- only one bit is set to '0', since all from SEC_addr must be '1' to enable IO
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (valid_addr = '1') then
				addr_BUS <= addr;
			else
				addr_BUS(n-1) <= '0';
				-- addr_BUS <= (others => '0');
			end if;
		end if;
	end process;

------------------------------------------------
-- io specific device enable flags
	cs_UART	<= cs_UART_ctrl AND cs_UART_data AND cs_UART_bd;

	cs_UART_ctrl <=	'0' when (addr_io = LSB_UART_CTRL AND en_io = '1') else
					'1';

	cs_UART_data <= '0' when (addr_io = LSB_UART_DATA AND en_io = '1') else
					'1';

	cs_UART_bd	 <= '0' when (addr_io = LSB_UART_BD AND en_io = '1')	else
					'1';

	cs_TIMER0	 <=	'0'	when (addr_io = LSB_TIMER0 AND en_io = '1') else
					'1';

------------------------------------------------
-- data input/output
	-- in
	data_in_UART <= data_io(nUART-1 downto 0);
	
	-- out
	data_io	<=	x"000000"&data_out_UART	when (cs_UART = '0' and we = '0') else
				data_T0					when (cs_TIMER0 = '0' and we = '0') else
				(others => 'Z');

------------------------------------------------
-- port map
	-- uart instance
    UART_control_i:	UART_control port map
    (
		clk 	 	 => clk ,
		rst 		 => rst ,
		uart_intr	 => uart_intr,
	    we		 	 => we ,
	    RxD 		 => RxD ,
	    TxD			 => TxD ,
		cs_UART_ctrl => cs_UART_ctrl ,
		cs_UART_data => cs_UART_data ,
		cs_UART_bd	 => cs_UART_bd ,
		data_in 	 => data_in_UART ,
		data_out	 => data_out_UART
	);

	-- timer0 instance
	Timer0_i:  Timer0  port map
	(
		rst    	=> rst ,
	    clk     	=> clk ,
	    we      	=> we ,
	    cs_TIMER0 	=> cs_TIMER0 ,
	    data_in 	=> data_io ,
		data_T0 	=> data_T0
	);

end architecture behavior;
