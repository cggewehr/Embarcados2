-------------------------------------------------------------------------------
-- Title      : UART baud rate generator
-- Project    : Aulas VHDL
-------------------------------------------------------------------------------
-- File       : UART_clock_generator.vhd
-- Author     : Giovani Baratto  <Giovani.Baratto@ufsm.br>
-- Company    : UFSM - CT - DELC
-- Created    : 2017-04-24
-- Last update: 2017-06-18
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: baud rate generator to UART
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
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--! @brief Descrição em VHDL da entidade do gerador de baud rate da USART
--! @details Descrição em VHDL de um gerador de baud rate da USART. Este é um
--! circuito divisor de frequência. 
--! Cada borda de subida do pulso UART_clk, marca um bit de um quadro da comunicação.
--! A frequência do sinal USART_clk é dada por:
--! \f[ f_{USART\_clk} = \frac{f_{clk}}{16 \cdot (divisor+1)} \f].
--! Na saída UART_clk_16 a frequência é 16 vezes maior e dada pela sequinte equação:
--! \f[ f_{USART\_clk\_16} = \frac{f_{clk}}{divisor+1} \f]
--! @author Giovani Baratto (Giovani.Baratto@ufsm.br)
--! @version 0.1
--! @date 2017
--! @todo transmitir quadros com outros formatos
--! @image latex "block_diagram_uart_baud_rate_generator.eps" "Diagrama de bloco do gerador de baud da UART" width=10cm
--! @image html  "block_diagram_uart_baud_rate_generator.png" "Diagrama de bloco do gerador de baud da UART" width=800
entity UART_baud_rate_generator is
  generic(n_bits : positive := 16);     --! número de bits do divisor
  port(divisor     : in  std_logic_vector((n_bits-1) downto 0);  --! divide a frequência de clk do sistema
       UART_clk_16 : out std_logic;     --! 16 * relógio da UART
       UART_clk    : out std_logic;     --! relógio da UART
       clk         : in  std_logic;     --! relógio do sistema
       rst         : in  std_logic);    --! reset assínncrono do sistema
end entity UART_baud_rate_generator;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
architecture simple of UART_baud_rate_generator is
  signal counter    : unsigned(divisor'range);  --! contador para realizar a divisão da frequência de relógio por 16 * (divisor+1)
  signal counter_16 : unsigned(3 downto 0); 
  signal last_count : std_logic;        --! '1' indica que counter está no último valor de contagem
begin

  last_count  <= '1' when std_logic_vector(counter) = divisor      else '0';
  UART_clk_16 <= last_count;
  UART_clk    <= '1' when last_count = '1' and counter_16 = "1111" else '0';

  --! @brief Gera a taxa de transmissão de dados.
  --! @details Se rst = '1' todos os contadores do divisor são zerados.
  --! A cada divisor+1 pulsos do sinal de relógio do sistema, é gerado um
  --! pulso na saída UART_clk_16. A cada 16 pulsos de UART_clk_16 ou a cada
  --! 16 * divisor  pulsos do sinal de relógio do sistema é gerado um pulso
  --! na saída UART_clk.
  baud_rate_p : process(clk, rst)
  begin
    if (rst = '1') then -- se rst for igual a '1' zeramos o contador do divisor de frequência
      counter    <= (others => '0');
      counter_16 <= (others => '0');
    elsif (rising_edge(clk)) then
      if (last_count = '1') then
        counter    <= (others => '0');
        counter_16 <= counter_16 + 1;
      else
        counter <= counter + 1;
      end if;
    end if;
  end process baud_rate_p;

end architecture simple;
-------------------------------------------------------------------------------
