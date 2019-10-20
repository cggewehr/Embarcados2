-------------------------------------------------------------------------------
-- Title      : UART
-- Project    :
-------------------------------------------------------------------------------
-- File       : UART.vhd
-- Author     : Giovani Baratto  <Giovani.Baratto@ufsm.br>
-- Company    : UFSM - CT - DELC
-- Created    : 2017-04-24
-- Last update: 2017-06-18
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2017
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2017-04-24  0.1      gfbaratto       Created
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.UART_pkg.all;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--! @brief sistema de transmissão e recepção UART
--! @details Este subsistema UART, transmite e recebe quadros 8N1, com 10 bits. A taxa de
--! transmissão é dada por UART_clk.
--! @author Giovani Baratto (Giovani.Baratto@ufsm.br)
--! @version 0.1
--! @date 2017
--! @todo receber e transmitir quadros com outros formatos
--! @image latex block_diagram_uart.eps "Diagrama de bloco da UART" width=\textwidth
--! @image html block_diagram_uart.png "Diagrama de bloco da UART" width=800
entity UART is
  generic(n_bits : positive := 16);     --! número de bits do divisor
  port(
    -- transmissor ports
    UART_Tx_data_in  : in  std_logic_vector(7 downto 0);          --! dado (byte) a ser transmitido pela  UART
    UART_Tx_data_out : out std_logic;   									--! saída serial do dado a ser transmitido
    UART_Tx_ready    : out std_logic;   									--! '1' sinaliza que não existe byte a ser transmitido
    UART_Tx_write    : in  std_logic;   									--! '1' (em um ciclo de relógio) envia o dado UART_Tx_data_in serialmente.
    -- receptor ports
    UART_RX_data_in  : in  std_logic;   									--! dado serial recebido pela UART
    UART_RX_data_out : out std_logic_vector(7 downto 0);          --! dado recebido pela UART
    UART_RX_new_data : out std_logic;   									--! '1' sinaliza que um novo dado (byte) foi recebido
    UART_RX_read     : in  std_logic;   									--! '1' indica que o dado recebido foi lido: um novo dado pode ser recebido
    -- UART clock, system clock and reset
    divisor          : in  std_logic_vector((n_bits-1) downto 0); --! divide a frequência de relógio do sistema.
    clk              : in  std_logic;   									--! relógio do sistema
    rst              : in  std_logic    									--! reset do sistema
    );
end entity UART;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
architecture simple of UART is
  signal UART_clk_16 : std_logic;
  signal UART_clk    : std_logic;
begin

  --! @brief instanciação do susbsistema gerador da taxa de transmissão
  UART_baud_rate_generator_1 : UART_baud_rate_generator
    generic map (
      n_bits => n_bits)
    port map (
      divisor     => divisor,
      UART_clk_16 => UART_clk_16,
      UART_clk    => UART_clk,
      clk         => clk,
      rst         => rst);

  --! @brief instanciação do subsistema para a transmissão de um dado(byte), serialmente
  UART_Tx_1 : UART_Tx
    port map (
      UART_Tx_data_in  => UART_Tx_data_in,
      UART_Tx_data_out => UART_Tx_data_out,
      UART_Tx_ready    => UART_Tx_ready,
      UART_Tx_write    => UART_Tx_write,
      UART_clk         => UART_clk,
      clk              => clk,
      rst              => rst);

  --! @brief instanciação do subsistema para a recepção serial.
  UART_RX_1 : UART_RX
    port map (
      UART_RX_data_in  => UART_RX_data_in,
      UART_RX_data_out => UART_RX_data_out,
      UART_RX_new_data => UART_RX_new_data,
      UART_RX_read     => UART_RX_read,
      UART_clk_16      => UART_clk_16,
      rst              => rst,
      clk              => clk);

end architecture simple;
-------------------------------------------------------------------------------
