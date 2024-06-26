# About

This is derived from the awesome work [here](https://github.com/Seelengrab/MCUCompiler.jl) and [here](https://seelengrab.github.io/articles/Running%20Julia%20baremetal%20on%20an%20Arduino/)

The original blogpost code still more-or-less works, but some library calls needed to be updated.

Also the dependencies are provided by Nix, so this should be relatively reproducible.

# Usage

To build the code, all prerequisites are sourced via Nix, so just run `nix-shell` to get the correct environment

To run the code on an AVR chip, you will need the following:
* an AVR chip (currently only atmega168 is supported)
* an ISP (eg an Arduino with the "ArduinoISP" sketch flashed to it)
* an LED to confirm the pin is being "blinked" correctly
* a breadboard to connect all the components up (like eg https://medium.com/@srmq/using-arduino-board-as-isp-to-program-atmega328-ic-without-a-crystal-667ef0fccf4)

Connect the LED between pin 15 and GND, with a suitable protective resistor in series.

```
nix-shell
make        # generates Julia AVR code and builds the hex file
make flash  # flashes the chip (builds the hexfile if needed)
```
