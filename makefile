
edit.bin: edit.asm
	asm02 -L -b edit.asm
	-rm edit.build

clean:
	rm edit.lst
	rm edit.bin

