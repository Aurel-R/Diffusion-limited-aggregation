all: 
	ghdl -a paq.vhd
	ghdl -a automate_cellulaire.vhd
	ghdl -a cell.vhd
	ghdl -a grid.vhd
	ghdl -a rand.vhd
	ghdl -a fsm.vhd
	ghdl -a bram.vhd
	ghdl -a hw_img.vhd
	ghdl -a vga_ctl.vhd
	ghdl -a automate_cellulaire_tb.vhd
	ghdl -e automate_cellulaire_tb
	echo "Run the test with: ./automate_cellulaire_tb --vcd=FILENAME.vcd" 
