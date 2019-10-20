-------------------------------------------------------------------------------
-- Title      : UART Receptor
-- Project    :
-------------------------------------------------------------------------------
-- File       : UART_RX.vhd
-- Author     : Giovani Baratto  <Giovani.Baratto@ufsm.br>
-- Company    : UFSM - CT - DELC
-- Created    : 2017-04-26
-- Last update: 2017-06-18
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: UART Receptor description
-------------------------------------------------------------------------------
-- Copyright (c) 2017
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2017-04-26  0.1      gfbaratto       Created
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--! @brief subsistema de recepo da UART
--! @details Este subsistema UART, recebe um quadro 8N1, com 10 bits. A taxa de
--! transmisso e dada por UART_clk.
--! @author Giovani Baratto (Giovani.Baratto@ufsm.br)
--! @version 0.1
--! @date 2017
--! @todo receber quadros com outros formatos
--! @image latex block_diagram_uart_rx.eps "Diagrama de bloco do receptor UART" width=10cm
--! @image html  block_diagram_uart_rx.png "Diagrama de bloco do receptor UART" width=800
entity UART_RX is
  port(UART_RX_data_in  : in  std_logic;  						--! dados de entrada seriais
       UART_RX_data_out : out std_logic_vector(7 downto 0); --! dado (byte) recebido pela entrada serial UART_RX_data_in
       UART_RX_new_data : out std_logic;  						--! '1' indica que um novo dado foi recebido
       UART_RX_read     : in  std_logic;  						--! '1' permite que novos dados sejam recebidos pela entrada serial
       UART_clk_16      : in  std_logic;  						--! 16 * relgio da UART
       rst              : in  std_logic;  						--! sinal de reset do sistema
       clk              : in  std_logic);                   --! relgio do sistema
end entity UART_RX;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
architecture simple of UART_RX is
  signal sample_register : std_logic_vector(2 downto 0);
  signal data_register   : std_logic_vector(7 downto 0);
  signal edge_neg        : std_logic;
  signal samples_equal   : std_logic;
  signal counter         : unsigned(3 downto 0);

  signal new_data             : std_logic;
  signal sample_counter       : unsigned(3 downto 0);
  signal data_counter         : unsigned(3 downto 0);
  signal sample_counter_clear : std_logic;
  signal data_counter_clear   : std_logic;
  signal enable               : std_logic;
  signal enable_clear         : std_logic;
  signal sample               : std_logic;
  signal transfer             : std_logic;

  signal tf_en	: std_logic; -- desabilita transfer após o primeiro pulso, evitando erros de temporização na recepção

begin

  enable_clear <= data_counter(3) and data_counter(1);
  sample       <= '1' when sample_counter = "0111" and UART_clk_16 = '1' else '0';
  transfer     <= '1' when data_counter = "1001" and UART_clk_16 = '1' and tf_en = '0'   else '0'; -- teste


  UART_RX_new_data <= new_data;

  enable_p : process(clk, rst)
  begin
    if (rst = '1') then
      enable <= '0';
    elsif(rising_edge(clk)) then
      if(enable = '0') then
        enable <= not (UART_RX_data_in or new_data);
      else
        enable <= not enable_clear;
      end if;
    end if;
  end process enable_p;

  sample_counter_p : process(clk, rst)
  begin
    if (rst = '1') then
      sample_counter <= (others => '0');
    elsif(rising_edge(clk)) then
      if(enable = '1') then
        if(UART_clk_16 = '1') then
          sample_counter <= sample_counter + 1;
        else
          sample_counter <= sample_counter;
        end if;
      else
        sample_counter <= (others => '0');
      end if;
    end if;
  end process sample_counter_p;


  data_counter_p : process(clk, rst)
  begin
    if(rst = '1') then
      data_counter <= (others => '0');
    elsif(rising_edge(clk)) then
      if(enable = '1') then
        if(sample = '1') then
          data_counter <= data_counter + 1;
        end if;
      else
        data_counter <= (others => '0');
      end if;
    end if;
  end process data_counter_p;

  data_register_p : process(clk, rst)
  begin
    if(rst = '1') then
      data_register <= (others => '0');
    elsif(rising_edge(clk)) then
      if(sample = '1') then
        data_register <= UART_RX_data_in & data_register(7 downto 1);
      end if;
    end if;
  end process data_register_p;

  data_out : process(clk, rst)
  begin
    if(rst = '1') then
      UART_RX_data_out <= (others => '0');
    elsif(rising_edge(clk)) then
      if(transfer = '1') then
        UART_RX_data_out <= data_register;
      end if;
    end if;
  end process data_out;

  process(clk, rst)
  begin
    if (rst = '1') then
      new_data <= '0';
	 elsif(rising_edge(clk)) then
      if(transfer = '1') then
        new_data <= '1';
	   elsif(UART_RX_read = '1') then
        new_data <= '0';
      end if;
    end if;
  end process;


 -- teste
  process(clk , rst)
  begin
	if (rst = '1') then
		tf_en <= '0';
	elsif (rising_edge(clk)) then
		if (transfer = '1') then
			tf_en <= '1';
		elsif (enable = '0') then
			tf_en <= '0';
		end if;
	 end if;
	end process;
-- teste

end architecture simple;
-------------------------------------------------------------------------------
