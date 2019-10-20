-------------------------------------------------------------------------------
-- Title      : Pacote do projeto da UART
-- Project    : UART
-------------------------------------------------------------------------------
-- File       : UART_pkg.vhd
-- Author     : Giovani Baratto  <Giovani.Baratto@ufsm.br>
-- Company    :
-- Created    : 2017-06-18
-- Last update: 2017-06-18
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Pacote com os procedimento, funções, constantes e componentes
--              usados na descrição de uma UART
-------------------------------------------------------------------------------
-- Copyright (c) 2017
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2017-06-18  0.1      Giovani Baratto Created
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--! brief pacote com os componentes usados na UART
package UART_pkg is

  --! @brief declaração do componente para a geração da taxa de transmissão
  component UART_baud_rate_generator is
    generic (
      n_bits : positive);
    port (
      divisor     : in  std_logic_vector((n_bits-1) downto 0);
      UART_clk_16 : out std_logic;
      UART_clk    : out std_logic;
      clk         : in  std_logic;
      rst         : in  std_logic);
  end component UART_baud_rate_generator;

  --! @brief declaração do componente para transmissão de dados (bytes) da UART
  component UART_TX is
    port (
      UART_TX_data_in  : in  std_logic_vector(7 downto 0);
      UART_TX_data_out : out std_logic;
      UART_TX_ready    : out std_logic;
      UART_TX_write    : in  std_logic;
      UART_clk         : in  std_logic;
      clk              : in  std_logic;
      rst              : in  std_logic);
  end component UART_Tx;

  --! @brief declaração do componente para a recepção dos dados (bytes) da UART
  component UART_RX is
    port (
      UART_RX_data_in  : in  std_logic;
      UART_RX_data_out : out std_logic_vector(7 downto 0);
      UART_RX_new_data : out std_logic;
      UART_RX_read     : in  std_logic;
      UART_clk_16      : in  std_logic;
      rst              : in  std_logic;
      clk              : in  std_logic);
  end component UART_RX;

  --! @brief declaração do componente UART
  component UART is
    generic (
      n_bits : positive);
    port (
      UART_Tx_data_in  : in  std_logic_vector(7 downto 0);
      UART_Tx_data_out : out std_logic;
      UART_Tx_ready    : out std_logic;
      UART_Tx_write    : in  std_logic;
      UART_RX_data_in  : in  std_logic;
      UART_RX_data_out : out std_logic_vector(7 downto 0);
      UART_RX_new_data : out std_logic;
      UART_RX_read     : in  std_logic;
      divisor          : in  std_logic_vector((n_bits-1) downto 0);
      clk              : in  std_logic;
      rst              : in  std_logic);
  end component UART;

end package UART_pkg;
-------------------------------------------------------------------------------
