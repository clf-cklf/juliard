PORT=/dev/ttyACM1
BAUD=19200
CHIP=atmega168

all: out.hex

clean:
	rm -f out.o out.elf out.hex

out.o: Main.jl
	julia Main.jl

out.elf: out.o
	avr-ld -o out.elf out.o

out.hex: out.elf
	avr-objcopy -O ihex out.elf out.hex

flash: out.hex
	avrdude -v -V -p$(CHIP) -cstk500v1 -P$(PORT) -b$(BAUD) "-Uflash:w:out.hex:i"
