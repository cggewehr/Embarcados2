library ieee;
use ieee.std_logic_1164.all;

package top_module_pkg is

	constant	n	:	integer := 32;

---------------------------
-- COMPONENT
	-- RV32I Core
	COMPONENT core
		port(
			clk			: in std_logic;
			rst			: in std_logic;
			intr		: in std_logic;
			we			: out std_logic;
			stall_icache: out std_logic;
			valid_iaddr	: out std_logic;
			valid_daddr	: out std_logic;
			wait_i		: in std_logic;
			wait_d		: in std_logic;
			sb_en		: out std_logic;
			sh_en		: out std_logic;
			addr_icache	: out std_logic_vector(n-1 downto 2);
			data_icache	: in std_logic_vector(n-1 downto 0);
			addr_dcache	: out std_logic_vector(n-1 downto 0);
			data_dcache	: inout std_logic_vector(n-1 downto 0)
		);
	end COMPONENT core;

	-- Instruction and Data Cache top module
	COMPONENT cache is
		port(
			clk			: in std_logic;
			rst			: in std_logic;
			-- icache ports
			stall_icache: in std_logic;
			valid_iaddr	: in std_logic;
			addr_icache	: in std_logic_vector(n-1 downto 2);
			data_icache	: out std_logic_vector(n-1 downto 0);
			wait_i		: out std_logic;
			-- dcache ports
			valid_daddr	: in std_logic;
			we 			: in std_logic;
			sh_en		: in std_logic;
			sb_en		: in std_logic;
			addr_dcache	: in std_logic_vector(n-1 downto 0);
			data_dcache	: inout std_logic_vector(n-1 downto 0);
			wait_d		: out std_logic;
			-- cache control
			rst_cache	: out std_logic;
			cancel_ir	: out std_logic;
			ir_cache	: in std_logic;
			dr_cache	: in std_logic;
			drw_cache	: in std_logic;
			ir_miss		: out std_logic;
			dr_miss		: out std_logic;
			dr_miss_hold: in std_logic;
			wb_en		: out std_logic;
			ready_cache	: in std_logic;
			addr_ir		: out std_logic_vector(n-1 downto 0);
			addr_dr_drw	: out std_logic_vector(n-1 downto 0);
			din_cache	: in std_logic_vector(n-1 downto 0);
			dout_cache	: out std_logic_vector(n-1 downto 0)
		);
	end COMPONENT cache;

	-- Cache Memory Control
	COMPONENT cache_ctrl is
		port(
			clk				: in std_logic;
			-- request status, connection with icache and dcache
			rst_cache		: in std_logic;
			cancel_ir		: in std_logic;
			ir_cache		: out std_logic;
			dr_cache		: out std_logic;
			drw_cache		: out std_logic;
			ir_miss			: in std_logic;
			dr_miss			: in std_logic;
			dr_miss_hold	: out std_logic;
			wb_en			: in std_logic;
			ready_cache		: out std_logic;
			addr_ir			: in std_logic_vector(n-1 downto 0);
			addr_dr_drw		: in std_logic_vector(n-1 downto 0);
			din_cachectl	: in std_logic_vector(n-1 downto 0);
			dout_cachectl	: out std_logic_vector(n-1 downto 0);
			-- connections with the main mem
			stop_req		: out std_logic;
			we_req			: out std_logic;
			ack_req			: in std_logic;
			ready_req		: in std_logic;
			request			: out std_logic;
			addr_bus		: out std_logic_vector(n-1 downto 0);
			data_bus		: inout std_logic_vector(n-1 downto 0)
		);
    end COMPONENT cache_ctrl;

	-- IO Section
	COMPONENT IO is
        port(
			rst			: in std_logic;
			clk     	: in std_logic;
			io_intr		: out std_logic;
			valid_addr	: in std_logic;
            addr    	: in std_logic_vector(n-1 downto 0);
            we      	: in std_logic;
            data_io 	: inout std_logic_vector(n-1 downto 0);
            RxD     	: in std_logic;
			TxD     	: out std_logic
		);
	end COMPONENT IO;
	
end package top_module_pkg;
