as:
	as219x -2191 -I ./ -o main.out main.asm
	as219x -2191 -I ./ -o init.out init.asm
	as219x -2191 -I ./ -o isr.out isr.asm
	as219x -2191 -I ./ -o myfilter.out myfilter.asm
	as219x -2191 -I ./ -o processing.out processing.asm
	as219x -2191 -I ./ -o rotary_encoder.out rotary_encoder.asm
	as219x -2191 -I ./ -o lcd.out lcd.asm
	as219x -2191 -I ./ -o stateandhelpers.out stateandhelpers.asm
	ld21 -o lab3.dxe -T stud-1.ldf main.out isr.out myfilter.out init.out processing.out  lcd.out rotary_encoder.out stateandhelpers.out
	loader lab3.dxe -o lab3.bin
