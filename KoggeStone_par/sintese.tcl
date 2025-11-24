# 1. Ler o arquivo VHDL
read_vhdl KoggeStone_par.vhd

# 2. Rodar a Síntese para a FPGA Basys 3
# top = nome da entity principal
# part = código do chip da Basys 3
synth_design -top KoggeStone_par -part xc7a35tcpg236-1

# 3. (Opcional) Gerar relatório de uso de área
report_utilization -file utilizacao.txt

# 4. Rode o script de sintese com o comando:
# vivado -mode batch -source sintese.tcl