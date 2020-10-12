#include "mmio.h"


#define frameWidth 320
#define frameHeight 240
#define bytesPerPixel 2
#define buffSize frameHeight*frameWidth*bytesPerPixel


void main(void){
int ddr [buffSize];
int i = 0;
int burst_size;
int cmd;

while (1){
	write_led(1);
	cmd = read_uart();			// get command from UART
	write_led(0);
	int data;
	
	if (cmd == 0){			// read I2C
		write_led(2);
		int d1 = read_uart();
		data = read_i2c(d1);
		write_uart(data);
	}
	
	else if (cmd == 1){		// write I2C
		write_led(3);
		int d1 = read_uart();
		int d2 = read_uart();
		write_i2c(d1,d2);
		write_uart(d2);
	}
	
	else if (cmd == 2){		// read SPI
		write_led(4);
		int d1 = read_uart();
		data = read_spi(d1);
		write_uart(data);
	}
	
	else if (cmd == 3){		// write SPI
		write_led(5);
		int d1 = read_uart();
		int d2 = read_uart();
		write_spi(d1,d2);
		write_uart(d2);
	}
	
	else if (cmd == 4){		// read DRAM
		write_led(6);
		int d1 = read_uart();
		int d2 = read_uart();
		int d3 = read_uart();
		int d4 = read_uart();
		int addr = _c2i(d4,d3,d2,d1);
		if (addr >= buffSize)
			addr = 0;
		data = ddr[addr];
		write_uart(_i2c(data,0));
		write_uart(_i2c(data,1));
		write_uart(_i2c(data,2));
		write_uart(_i2c(data,3));
	}
	
	else if (cmd == 5){		// write DRAM
		write_led(7);
		int d1 = read_uart();
		int d2 = read_uart();
		int d3 = read_uart();
		int d4 = read_uart();
		int d5 = read_uart();
		int d6 = read_uart();
		int d7 = read_uart();
		int d8 = read_uart();
		int addr = _c2i(d4,d3,d2,d1);
		if (addr >= buffSize)
			write_uart(0);
		else{
		data = _c2i(d8,d7,d6,d5);
		ddr[addr]  = data;
		write_uart(1);
		}
	}

	else if (cmd == 6){		// capture Image
		write_led(8);
		int j = 0;
		write_spi(0x01,0x00);  // capture a single image
		write_spi(0x04,0x01);	// flush fifo
		write_spi(0x04,0x01);  // clear it again (from the arduino code)
		write_spi(0x04,0x02);  // start capture
		while (((read_spi(0x41) >> 3) & 1) == 0); // wait till the write is complete
		int fifolength = buffSize;	
		for (j=0; j < fifolength; j++){
			int a = read_spi(0x3D);
			int b = read_spi(0x3D);
			int c = read_spi(0x3D);
			int d = read_spi(0x3D);
			ddr[j] = _c2i(d,c,b,a); 
		}
		// return fifo size
		write_uart(read_spi(0x44)); 
		write_uart(read_spi(0x43));
		write_uart(read_spi(0x42));
	}
	
	else if (cmd == 7){			// send Image data to host in bursts
		write_led(9);
		int j = i;
		for (; i < (j+burst_size); i++){
			data = ddr[i];
			write_uart(_i2c(data,0));
			write_uart(_i2c(data,1));
			write_uart(_i2c(data,2));
			write_uart(_i2c(data,3));
		}
	}
	else if (cmd == 8){		 	// set burst size and reset send counter
		write_led(10);
		int d1 = read_uart();
		int d2 = read_uart();
		int d3 = read_uart();
		int d4 = read_uart();
		burst_size = _c2i(d4,d3,d2,d1);
		i = 0;
	}	
	
	else if (cmd == 9){		 	// interace custom logic
		write_led(11);	
		int d1 = read_uart();
		int d2 = read_uart();
		write_uart(cl(d1,d2));
	}
}
return;
}
