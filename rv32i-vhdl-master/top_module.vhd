library ieee;
use ieee.std_logic_1164.all;
use work.top_module_pkg.all;
use work.cellram_pkg.all;

entity top_module is
	port
	(
		clk  	: in std_logic;	-- sinal de clock
		rst_bt	: in std_logic;	-- sinal de reset, passa por lgica de debouncing
		--- UART
		RxD   	: in std_logic;	-- sinal de recepo da UART
		TxD   	: out std_logic; -- sinal de transmisso da UART
		--- Cellular RAM
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
end entity top_module;

architecture behavior of top_module is

	COMPONENT bt_debounce is
		port
		(
			clk		:	in std_logic;
			bt_in	:	in std_logic;
			bt_out	:	out std_logic
		);
	end COMPONENT bt_debounce;

	-- System reset
	signal	rst_int	:	std_logic := '1';
	signal	rst_db	:	std_logic;
	signal	rst		:	std_logic;

	-- Core control to/from Cache
	signal	stall_icache:	std_logic;
	signal	valid_iaddr	:	std_logic;
	signal	wait_i		:	std_logic;
	signal	valid_daddr	:	std_logic;
	signal	wait_d		:	std_logic;
	signal	sb_en		:	std_logic;
	signal	sh_en		:	std_logic;
	signal	we			:	std_logic;

	-- Cache
	signal	addr_icache	:	std_logic_vector(n-1 downto 2);
	signal	data_icache	:	std_logic_vector(n-1 downto 0);
	signal	addr_dcache	:	std_logic_vector(n-1 downto 0);
	signal	data_dcache	:	std_logic_vector(n-1 downto 0);

	-- Cache Control
	signal	rst_cache	:	std_logic;
	signal	cancel_ir	:	std_logic;
	signal	ir_cache	:	std_logic;
	signal	ir_miss		:	std_logic;
	signal	addr_ir		:	std_logic_vector(n-1 downto 0);

	signal	dr_cache	:	std_logic;
	signal	drw_cache	:	std_logic;
	signal	dr_miss		:	std_logic;
	signal	dr_miss_hold:	std_logic;
	signal	wb_en		:	std_logic;
	signal	addr_dr_drw	:	std_logic_vector(n-1 downto 0);

	signal	ready_cache	:	std_logic;
	signal	din_cache	:	std_logic_vector(n-1 downto 0);
	signal	dout_cache	:	std_logic_vector(n-1 downto 0);

	-- I/O
	signal	io_intr			:	std_logic;
	signal	valid_ioaddr	:	std_logic;
	signal	addr_io			:	std_logic_vector(n-1 downto 0);

	-- RAM Interface
	signal	stop_req	:	std_logic;
	signal	ack_req		:	std_logic;
	signal	ready_req	:	std_logic;
	signal	we_req		:	std_logic;
	signal	request		:	std_logic;
	signal	addr_bus	:	std_logic_vector(n-1 downto 0);
	signal	data_bus	:	std_logic_vector(n-1 downto 0);

begin

	---------
	-- I/O
	valid_ioaddr<=	valid_daddr;
	addr_io		<=	addr_dcache;

	------------------------------------------------
	--- System Reset Process
	rst_internal :	process (clk)
	begin
		if (rising_edge(clk)) then
			if (rst_db = '1') then
				rst_int <= '0';
			end if;
		end if;
	end process rst_internal;

	rst <= rst_db OR rst_int;	-- system reset

-- Port Map
	-- core instance
	core_i:	core
	port map(
		rst 	   	=> rst ,
		clk 	   	=> clk ,
		intr		=> io_intr,
		we 		   	=> we ,
		stall_icache=> stall_icache,
		valid_iaddr	=> valid_iaddr,
		valid_daddr	=> valid_daddr,
		wait_i		=> wait_i,
		wait_d		=> wait_d,
		sb_en 	   	=> sb_en ,
		sh_en	   	=> sh_en ,
		addr_icache	=> addr_icache ,
		data_icache	=> data_icache ,
		addr_dcache	=> addr_dcache , 
		data_dcache => data_dcache
	);

	-- instruction and data cache top module instance
	cache_i: cache
	port map(
		clk		=> clk,
		rst		=> rst,
		-------------------
		stall_icache=> stall_icache,
		valid_iaddr	=> valid_iaddr,
		addr_icache	=> addr_icache,
		data_icache	=> data_icache,
		wait_i		=> wait_i,
		-------------------
		valid_daddr	=> valid_daddr,
		we 			=> we,
		sh_en		=> sh_en,
		sb_en		=> sb_en,
		addr_dcache	=> addr_dcache,
		data_dcache	=> data_dcache,
		wait_d		=> wait_d,
		-------------------
		rst_cache	=> rst_cache,
		cancel_ir	=> cancel_ir,
		ir_cache	=> ir_cache,
		dr_cache	=> dr_cache,
		drw_cache	=> drw_cache,
		ir_miss		=> ir_miss,
		dr_miss		=> dr_miss,
		dr_miss_hold=> dr_miss_hold,
		wb_en		=> wb_en,
		ready_cache	=> ready_cache,
		addr_ir		=> addr_ir,
		addr_dr_drw	=> addr_dr_drw,
		din_cache	=> din_cache,
		dout_cache	=> dout_cache
	);

	-- cache ctrl instance
	cache_ctrl_i: cache_ctrl
	port map(
		clk 	   	=> clk ,
		-----------------------------
		rst_cache	=> rst_cache,
		cancel_ir	=> cancel_ir,
		ir_cache	=> ir_cache,
		dr_cache	=> dr_cache,
		drw_cache	=> drw_cache,
		ir_miss		=> ir_miss,
		dr_miss		=> dr_miss,
		dr_miss_hold=> dr_miss_hold,
		wb_en		=> wb_en,
		ready_cache	=> ready_cache,
		addr_ir		=> addr_ir,
		addr_dr_drw	=> addr_dr_drw,
		din_cachectl=> dout_cache,
		dout_cachectl=>din_cache,
		-----------------------------
		stop_req	=> stop_req,
		ack_req		=> ack_req,
		ready_req	=> ready_req,
		request		=> request,
		we_req		=> we_req,
		addr_bus	=> addr_bus,
		data_bus	=> data_bus
	);

	-- io ctrl instance
	io_i: IO
	port map(
		rst 		=> rst,
		clk 		=> clk,
		io_intr		=> io_intr,
		valid_addr	=> valid_ioaddr,
		we	 		=> we ,
		addr 		=> addr_io ,
		data_io 	=> data_dcache,
		RxD 		=> RxD ,
		TxD 		=> TxD
	);

	-- cellular ram interface instance
	cellram_interface_i: cellram_interface
	port map(
		clk			=> clk,
		--------------------
		stop_req	=> stop_req,
		ready_req	=> ready_req,
		ack_req		=> ack_req,
		request		=> request,
		we_req		=> we_req,
		addr_bus	=> addr_bus(n_ramaddr-1+1 downto 1),
		data_bus	=> data_bus,
		--------------------
		cre_r		=> cre_r,
		ce_r		=> ce_r,
		oe_r		=> oe_r,
		ub_r		=> ub_r,
		lb_r		=> lb_r,
		we_r		=> we_r,
		clk_r		=> clk_r,
		adv_r		=> adv_r,
		wait_r		=> wait_r,
		addr_ram	=> addr_ram,
		data_ram	=> data_ram
	);

	---------------------------------------------
	----- RESET BUTTON DEBOUNCE
	rst_bt_debounce_i:	bt_debounce
	port map
	(
		clk		=> clk,
		bt_in	=> rst_bt,
		bt_out	=> rst_db
	);

end architecture behavior;
