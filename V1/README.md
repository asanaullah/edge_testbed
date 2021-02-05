# Edge Testbed

Tested on the Arty A735T board

Tested with Vivado v2017.2 and v2020.1 

Supported camera module: Arducam 2MP Plus OV2640 Mini Module 

- https://www.arducam.com/product/arducam-2mp-spi-camera-b0067-arduino/
- https://www.amazon.com/Arducam-Module-Megapixels-Arduino-Mega2560/dp/B012UXNDOY 

___________________________________________

SW[0] : Global reset (active high)

SW[1] : Reprogram  (active high)

Programs need to be reloaded after a global reset (SW[0]) since the dram controller will overwrite some locations during callibration.
Toggling Reporgram pin does a soft reset - program does not need to be reloaded  

run ```make all``` to compile the design

run ```make prog``` to program the FPGA

run ```make load``` while SW[1] is high to load the program

Interface the provided test program using the jupyter notebook: sw/interfaceOV.ipynb

___________________________________________

Current work:
- adding comments
- proactively fixing a potential future bug in the reset

Future non-critical work:
Parameterize the remaining data and address widths




