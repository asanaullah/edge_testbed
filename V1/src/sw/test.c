#include "mmio.h"
#include <stdarg.h>

extern int debug asm ("DEBUG");
extern int timer asm ("TIMER");
const char digits[16] = {'0','1','2','3','4','5','6','7','8','9', 'A', 'B', 'C', 'D', 'E', 'F'};

void sleep(int microseconds)
{
  int start = timer;
  while ((timer-start) < microseconds);
}

void prints(char *str)
{
  int i=0;

  while((int)str[i] !=0)
  {
    debug = str[i];
    i = i+1;
  }
}

void printi(int val)
{
  if(val==0)
  {
    debug = '0';
    return;
  }

  if(val<0)
  {
    debug = '-';
    val = val*-1;
  }

  int num[10];

  for(int i=0;i<10;i++)
  {
    num[i] = val - 10*(val/10);
    val = val/10;
  }

  int start = 0;

  for (int i=10; i>0; i--)
  {
    if(start)
      debug = digits[num[i-1]];
    else if(num[i-1] > 0)
    {
      debug = digits[num[i-1]];
      start = 1;
    }
    else
      debug = 0;
  }
}

void printf(char *c, ...)
{
  char *s;
  va_list lst;
  va_start(lst, c);

  while(*c != '\0')
  {
    if(*c != '%')
    {
      debug = *c;
      c++;
      continue;
    }

    c++;

    if(*c == '\0')
      break;

    switch(*c)
    {
      case 's': prints(va_arg(lst, char *)); break;
      case 'd': printi(va_arg(lst, int)); break;
    }
    c++;
  }
}

void putchar(int c)
{
  debug = c;
}

void puts(char* s)
{
  prints(s);
}

void main(void)
{
  int count = 0;
  int data = 55;
  const int restart = 99;
  int digT1msb, digT1lsb, digT2msb, digT2lsb, digT3msb, digT3lsb;
  int digT1, digT2, digT3;
  int temp[3]; int temp_reading;
  int var1; int var2;
  int temp_comp;

  digT1lsb = read_i2c(0x88); digT1msb = read_i2c(0x89);
  digT1 = ((digT1msb & 0x000000FF)<<8) | (digT1lsb & 0x000000FF);

  digT2lsb = read_i2c(0x8A); digT2msb = read_i2c(0x8B);
  digT2 = ((digT2msb & 0x000000FF)<<8) | (digT2lsb & 0x000000FF);

  digT3lsb = read_i2c(0x8C); digT3msb = read_i2c(0x8D);
  digT3 = ((digT3msb & 0x000000FF)<<8) | (digT3lsb & 0x000000FF);

  while (1)
  {
#if 1
    data = read_i2c(0xD0);
    data &= 0x000000FF;
    temp[0] = read_i2c(0xFA); temp[0] &= 0x000000FF;
    temp[1] = read_i2c(0xFB); temp[1] &= 0x000000FF;
    temp[2] = read_i2c(0xFC); temp[2] &= 0x0000000F;

    temp_reading = (temp[0] >> 20) | (temp[1] >> 12) | temp[2];

    var1 = ((((temp_reading>>3) - (digT1<<1))) * digT2) >> 11;
    var2 = (((((temp_reading>>4) - digT1) * ((temp_reading>>4) - digT1)) >> 12 ) * digT3) >>14;
    temp_comp = ((var1+var2)*5 + 128) >> 8;

    printf("{\"topic\":\"sensor\",\"message\":\"{\\\"sensor_id\\\":%d,%d}\"}",data,count);
    printf("\r\n");
    printf("{\"topic\":\"sensor\",\"message\":\"{\\\"temperature\\\":%d,%d}\"}",temp_comp,count);
    printf("\r\n");
    putchar(0x0D);
    count = (++count==restart)?0:count;
#else
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
#endif
}
return;
}
