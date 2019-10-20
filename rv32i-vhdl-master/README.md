# Arquivos de Síntese/Implementação

Consistem em todos os presentes nesse repositório, com exceção dos contidos no diretório _testbench_.

# Arquivos de testbench

O testbench é realizado com os arquivos do diretório _testbench_, como descrições VHDL de topo do sistema, sobre todos os demais arquivos do repositório.

# Arquivos da Interface da RAM

O controlador da RAM está descrito no seu repositório próprio, sendo os arquivos:

- cellram_interface.vhd
- cellram_pkg.vhd
- cellram_interface.ucf

A execução de testbenchs com a RAM utiliza ainda os modelos descritos em Verilog da MICRON.

# Síntese da Cache

A memória cache do processador é inicializada no momento de síntese/implementação por meio de um programa no formato hexadecimal da intel. Supostamente, o código utilizado corresponde a algum teste, ou então, ao bootloador do sistema. O arquivo _'cache_pkg.vhd'_ utiliza de constantes do tipo _string_, indicando o diretório no qual se encontra o arquivo hexadecimal. O diretório principal deste repositório contém um programa hexadecimal para se realizar a síntese.
