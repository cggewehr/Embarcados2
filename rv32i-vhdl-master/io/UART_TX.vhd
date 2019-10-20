-------------------------------------------------------------------------------
-- Title      : UART_TX
-- Project    : UART
-------------------------------------------------------------------------------
-- File       : UART_TX.vhd
-- Author     : Giovani Baratto  <gfbaratto@UFSM-notebook>
-- Company    : UFSM - CT - DELC
-- Created    : 2017-04-26
-- Last update: 2017-06-18
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
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
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--! @brief subsistema de transmissão da UART
--! @details Este subsistema UART, transmite um quadro 8N1, com 10 bits. A taxa de
--! transmissão é dada por UART_clk.
--! @author Giovani Baratto (Giovani.Baratto@ufsm.br)
--! @version 0.1
--! @date 2017
--! @todo transmitir quadros com outros formatos
--! @image latex block_diagram_uart_tx.eps "Diagrama de bloco do transmissor UART" width=10cm
--! @image html block_diagram_uart_tx.png "Diagrama de bloco do transmissor UART" width=800
entity UART_TX is
  port(UART_TX_data_in  : in  std_logic_vector(7 downto 0);  --! vetor com dados de entrada
       UART_TX_data_out : out std_logic;                     --! saída dos dados de entrada, transmitidos serialmente
       UART_TX_ready    : out std_logic;                     --! se '1', novos dados de entrada são aceitos
       UART_TX_write    : in  std_logic;                     --! se '1', envia UART_TX_data_in
       UART_clk         : in  std_logic;                     --! relógio do transmissor UART
       clk              : in  std_logic;                     --! relógio do sistema
       rst              : in  std_logic);                    --! reset assíncrono do transmissor
end entity UART_TX;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
architecture simple of UART_TX is

  constant bits_in_frame : integer := 10;                           --! número de bits em um quadro
  signal sh_register     : std_logic_vector(0 to bits_in_frame-1);  --! registrador de deslocamento
  signal counter         : integer range 0 to bits_in_frame;        --! conta o número de bits que devem ser enviados
  
begin

  UART_Tx_ready <= '1' when counter = 0 else '0';  -- se '1', UART pronta para enviar novos dados

  --! 
  UART_TX_p : process(UART_Tx_write, clk, rst)
  begin
    if (rst = '1') then                 					-- se reset = '1'
      sh_register      <= (others => '0');           	-- o registrador de deslocamento é zerado
      UART_Tx_data_out <= '1';          					-- a saída é colocada em '1'
      counter          <= 0;  								-- o contador de bits a ser enviado é zerado: não existem bits para serem enviados
		
    elsif (rising_edge(clk)) then      					-- senão, se temos uma borda de subida do sinal de relégio
      if (counter /= 0) then            					-- se existem bits a serem transmitidos
        if (UART_clk = '1') then        					-- se temos um pulso do relógio da UART, podemos transmitir novo bit
          UART_Tx_data_out <= sh_register(bits_in_frame-1);  				-- enviamos o próximo bit do registrador de deslocamento
          sh_register      <= '1' & sh_register(0 to bits_in_frame-2);  -- deslocamos o registrador de deslocamento
          counter          <= counter - 1;           	-- decrementamos o contador: mais um bit foi enviado
        end if;
		  
      elsif (UART_Tx_write = '1') then  					-- se counter=0 (sem bits para enviar) e temos uma solicitação de envio de novo byte
        sh_register <= '1' & UART_Tx_data_in & '0';  	-- registramos no registrador de deslocamento um quadro para transmissão 
        counter     <= bits_in_frame;   					-- atualizamos o número de bits que serão transmitidos
      end if;
    end if;
  end process UART_TX_p;

end architecture simple;
-------------------------------------------------------------------------------
