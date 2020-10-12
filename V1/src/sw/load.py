import serial
import time
import sys


if (len(sys.argv) == 1):
	ser = serial.Serial('/dev/ttyUSB1', 1000000)
else:
	device = "/dev/" + sys.argv[1]
	ser = serial.Serial(device, 1000000)


program = []
address = []
counter = 0;
with open('firmware.hex') as file:
    for line in file:
        if "@" in line: 
            counter = int(line.split('@')[1],16)
        else:
            nl_rm_line =  line.split('\n')[0];  
            nl_rm_line =  nl_rm_line.split(' ');   
            if len(nl_rm_line) == 0: continue
            words = int(len(nl_rm_line)/4)
            for i in range(words):
                program.append(nl_rm_line[4*i+3] + nl_rm_line[4*i+2] + nl_rm_line[4*i+1] + nl_rm_line[4*i])
                address.append(counter)
                counter = counter + 4;
              
            
for i in range(len(program)):
    x = address[i]
    x1 = (x&255).to_bytes(1, byteorder='big')
    x2 = ((x>>8)&255).to_bytes(1, byteorder='big')
    x3 = ((x>>16)&255).to_bytes(1, byteorder='big')
    x4 = ((x>>24)&255).to_bytes(1, byteorder='big')
    ser.write(x1)
    time.sleep(0.001)
    ser.write(x2)
    time.sleep(0.001)
    ser.write(x3)
    time.sleep(0.001)
    ser.write(x4)
    time.sleep(0.001)
    x = int(program[i],16)
    x1 = (x&255).to_bytes(1, byteorder='big')
    x2 = ((x>>8)&255).to_bytes(1, byteorder='big')
    x3 = ((x>>16)&255).to_bytes(1, byteorder='big')
    x4 = ((x>>24)&255).to_bytes(1, byteorder='big')
    ser.write(x1)
    time.sleep(0.001)
    ser.write(x2)
    time.sleep(0.001)
    ser.write(x3)
    time.sleep(0.001)
    ser.write(x4)
    time.sleep(0.001)

print ("done")
