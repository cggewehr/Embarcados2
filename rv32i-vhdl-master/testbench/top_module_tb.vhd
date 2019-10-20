library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.cellram_tb_pkg.all;

entity top_module_tb is
end entity top_module_tb;

architecture behavior of top_module_tb is

	-- processor top module component
	COMPONENT top_module is
		port
		(
			clk  	: in std_logic;
			rst_bt	: in std_logic;
			RxD   	: in std_logic;
			TxD   	: out std_logic;
			cre_r	: out std_logic;
			ce_r	: out std_logic;
			oe_r	: out std_logic;
			ub_r	: out std_logic;
			lb_r	: out std_logic;
			we_r	: out std_logic;
			clk_r	: out std_logic;
			adv_r	: out std_logic;
			wait_r	: in std_logic;
			addr_ram: out std_logic_vector(n_ramaddr-1 downto 0);
			data_ram: inout std_logic_vector(n_ram-1 downto 0)
		);
	end COMPONENT top_module;

	-- cellram simulation model component
	COMPONENT cellram is
		port(
			clk		: in std_logic;
			adv_n	: in std_logic;
			cre		: in std_logic;
			o_wait	: out std_logic;
			ce_n	: in std_logic;
			oe_n	: in std_logic;
			we_n	: in std_logic;
			lb_n	: in std_logic;
			ub_n	: in std_logic;
			addr	: in std_logic_vector(n_ramaddr-1 downto 0);
			dq		: inout std_logic_vector(n_ram-1 downto 0)
		);
	end COMPONENT cellram;

	-- uart simulation model component
	COMPONENT top_module_uart is
		port
		(
			RxD			:	in std_logic;
			TxD			:	out std_logic;
			-------------------------------
			clk			:	in std_logic;
			rst			:	in std_logic
		);
	end COMPONENT top_module_uart;

	-- System clock and reset
	signal clk   : std_logic;
	signal rst_bt: std_logic;

	constant half_period : time := 5 ns;

	-- UART
	signal RxD_processor	:	std_logic;
	signal TxD_processor	:	std_logic;

	-- Cellular RAM
	signal	cre_r	:	std_logic;
	signal	ce_r	:	std_logic;
	signal	oe_r	:	std_logic;
	signal	ub_r	:	std_logic;
	signal	lb_r	:	std_logic;
	signal	we_r	:	std_logic;
	signal	clk_r	:	std_logic;
	signal	adv_r	:	std_logic;
	signal	wait_r	:	std_logic;
	signal	addr_ram:	std_logic_vector(n_ramaddr-1 downto 0);
	signal	data_ram:	std_logic_vector(n_ram-1 downto 0);

begin

	-- Clock process: 100 MHz
	signal_clk : process
	begin
		clk <= '0';		wait for half_period;
		loop
			clk <= '1';	wait for half_period;
			clk <= '0';	wait for half_period;
		end loop;
	end process signal_clk;

	-- Processo de gerao do sinal de reset
	rst_button : process	-- debounce should be disabled inside 'top_module/bt_dbounce' (stability time ~0)
	begin
		rst_bt <= '0';			wait for 100 ns;
		loop
			rst_bt <= '1';		wait for 100 ns;
			rst_bt <= '0';		wait for 10 sec;
			rst_bt <= '1';		wait for 100 ns;
			rst_bt <= '0';		wait for 2 sec;
		end loop;
	end process rst_button;


	

-- Port Map
	top_module_i: top_module
	port map
	(
		clk		=> clk,
		rst_bt	=> rst_bt,
		----------------------
		RxD		=> RxD_processor,
		TxD		=> TxD_processor,
		----------------------
		clk_r	=> clk_r,
		adv_r	=> adv_r,
		cre_r	=> cre_r,
		wait_r	=> wait_r,
		ce_r	=> ce_r,
		oe_r	=> oe_r,
		we_r	=> we_r,
		lb_r	=> lb_r,
		ub_r	=> ub_r,
		addr_ram=> addr_ram,
		data_ram=> data_ram
	);

	cellram_i: cellram
	port map(
		clk		=> clk_r,
		adv_n	=> adv_r,
		cre		=> cre_r,
		o_wait	=> wait_r,
		ce_n	=> ce_r,
		oe_n	=> oe_r,
		we_n	=> we_r,
		lb_n	=> lb_r,
		ub_n	=> ub_r,
		addr	=> addr_ram,
		dq		=> data_ram
	);

	top_module_uart_i: top_module_uart
	port map
	(
		RxD		=> TxD_processor,
		TxD		=> RxD_processor,
		clk		=> clk,
		rst		=> rst_bt
	);

end architecture behavior;
