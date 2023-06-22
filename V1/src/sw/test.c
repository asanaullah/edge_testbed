#include "mmio.h"

#include <stdarg.h>
#include <stdint.h>
#include <stddef.h>

#define BME280_STANDBY_TIME_500_MS                (0x04)

extern int debug asm ("DEBUG");
extern int timer asm ("TIMER");
const char digits[16] = {'0','1','2','3','4','5','6','7','8','9', 'A', 'B', 'C', 'D', 'E', 'F'};

#define frameWidth 320
#define frameHeight 240
#define bytesPerPixel 2
#define buffSize frameHeight*frameWidth*bytesPerPixel

static void putchar(int c);
static void sleep(int microseconds);
static void prints(char *str);
static void printi(int val);
static void printf(char *c, ...);
static void putchar(int c);
static void puts(char* s);

static void sleep(int microseconds)
{
  int start = timer;
  while ((timer-start) < microseconds);
}

static void prints(char *str)
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

static void printf(char *c, ...)
{
  char *s;
  va_list lst;
  va_start(lst, c);
  int32_t val; 
  int32_t remainder;

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
      case 'h': 
		val = va_arg(lst, int); 
		printi(val/100); 
		putchar('.');     
		val = (val < 0)?(-1*val):val; 
		remainder = val % 100; 
		if(remainder < 10) 
		  putchar('0');
		printi(remainder); 
	break;
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

#define BME280_CONCAT_BYTES(msb, lsb)             (((uint16_t)msb << 8) | (uint16_t)lsb)
#define BME280_12_BIT_SHIFT                       12
#define BME280_8_BIT_SHIFT                        8
#define BME280_4_BIT_SHIFT                        4


void main(void)
{
  int ddr [buffSize];
  int i = 0;
  int burst_size;
  int cmd;

  uint8_t data = 0;
  int count = 0;

  uint8_t digT1msb, digT1lsb, digT2msb, digT2lsb, digT3msb, digT3lsb;
  uint16_t digT1;
  int16_t digT2, digT3;

  uint8_t temp[3]; 
  uint32_t uncomp_temp_reading;
  int32_t comp_temp_reading;
  int32_t var1; 
  int32_t var2;
  int32_t temp_comp;

  int32_t tmin = -4000;
  int32_t tmax = 8500;
  int32_t t_fine = 0;

  uint32_t dataXLSB, dataLSB, dataMSB; 
  uint8_t ctrlSettings = 0x00;

  digT1lsb = (uint8_t)read_i2c(0x88); digT1msb = (uint8_t)read_i2c(0x89);
  digT1 = BME280_CONCAT_BYTES(digT1msb, digT1lsb); 

  digT2lsb = (uint8_t)read_i2c(0x8A); digT2msb = (uint8_t)read_i2c(0x8B);
  digT2 = (int16_t)BME280_CONCAT_BYTES(digT2msb, digT2lsb); 

  digT3lsb = (uint8_t)read_i2c(0x8C); digT3msb = (uint8_t)read_i2c(0x8D);
  digT3 = (int16_t)BME280_CONCAT_BYTES(digT3msb, digT3lsb); 

  data = read_i2c(0xD0);
 
  if(data != 0x60)
  {
	 printf("Error, ID %d not equal to BME280 0x60!\r\n", data); 
  }
  ctrlSettings = (uint8_t)read_i2c(0xF4);
  ctrlSettings |= 0x23;
  write_i2c(0xF4, ctrlSettings);
  write_i2c(0xF5, 0x60);

  while (1)
  {
    temp[0] = (uint8_t)read_i2c(0xFA); 
    dataMSB = (uint32_t)temp[0] << BME280_12_BIT_SHIFT;
  
    temp[1] = (uint8_t)read_i2c(0xFB); 
    dataLSB = (uint32_t)temp[1] << BME280_4_BIT_SHIFT;
  
    temp[2] = (uint8_t)read_i2c(0xFC);
    dataXLSB = (uint32_t)temp[2] >> BME280_4_BIT_SHIFT;
  
    uncomp_temp_reading = dataMSB | dataLSB | dataXLSB;
    comp_temp_reading = 0;
  
    var1 = (int32_t)((uncomp_temp_reading / 8) - (digT1 * 2));
    var1 = (var1 * ((int32_t)digT2)) / 2048;
  
    var2 = (int32_t)((uncomp_temp_reading / 16) - ((int32_t)digT1));
    var2 = (((var2 * var2) / 4096) * ((int32_t)digT3)) / 16384;
  
    t_fine = var1 + var2;
    comp_temp_reading = (t_fine * 5 + 128) / 256;
 
    if (comp_temp_reading < tmin)
    {
        comp_temp_reading = tmin;
    }
    else if (comp_temp_reading > tmax)
    {
        comp_temp_reading = tmax;
    }

    printf("{\"topic\":\"sensor\",\"message\":\"{\\\"temperature\\\":%h}\"}",comp_temp_reading);
    putchar(0x04);
  }
}
