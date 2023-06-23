#include "mmio.h"

#include <stdarg.h>
#include <stdint.h>
#include <stddef.h>

#define BME280_STANDBY_TIME_500_MS                (0x04)
#define BME280_CONCAT_BYTES(msb, lsb)             (((uint16_t)msb << 8) | (uint16_t)lsb)
#define BME280_12_BIT_SHIFT                       12
#define BME280_8_BIT_SHIFT                        8
#define BME280_4_BIT_SHIFT                        4
#define BME280_ID_REGISTER			  0xD0
#define BME280_DEVICE_ID			  0x60
#define BME280_CTRL_MEAS_REGISTER	          0xF4
#define BME280_CONFIG_REGISTER			  0xF5

extern int debug asm ("DEBUG");
extern int timer asm ("TIMER");
const char digits[16] = {'0','1','2','3','4','5','6','7','8','9', 'A', 'B', 'C', 'D', 'E', 'F'};

uint16_t digT1;
int16_t digT2, digT3;

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

static void printi(int val)
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

  int num[10] = {0,0,0,0,0,0,0,0,0,0};

  for(int i=0;i<10;i++)
  {
    num[i] = val % 10; //- 10*(val/10);
    val = val/10;
    if (val==0)
    {
      break;
    }
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
		prints(".");     
		val = (val < 0)?(-1*val):val; 
		remainder = val % 100; 
		if(remainder < 10) 
		  prints("0");
		printi(remainder); 
	break;
    }
    c++;
  }
}

static void putchar(int c)
{
  debug = c;
}

static void puts(char* s)
{
  prints(s);
}

static void getTempCalibrationParameters(void)
{
  uint8_t digT1msb, digT1lsb, digT2msb, digT2lsb, digT3msb, digT3lsb;
  uint8_t temp[3]; 
  
  digT1lsb = (uint8_t)read_i2c(0x88); digT1msb = (uint8_t)read_i2c(0x89);
  digT1 = BME280_CONCAT_BYTES(digT1msb, digT1lsb); 
  
  digT2lsb = (uint8_t)read_i2c(0x8A); digT2msb = (uint8_t)read_i2c(0x8B);
  digT2 = (int16_t)BME280_CONCAT_BYTES(digT2msb, digT2lsb); 

  digT3lsb = (uint8_t)read_i2c(0x8C); digT3msb = (uint8_t)read_i2c(0x8D);
  digT3 = (int16_t)BME280_CONCAT_BYTES(digT3msb, digT3lsb); 

}

static void setBME280Config(void)
{
  uint8_t ctrlSettings = 0x00;
  
  ctrlSettings = (uint8_t)read_i2c(BME280_CTRL_MEAS_REGISTER); // Get current settings
  ctrlSettings |= 0x23; 				      // 1x temperature oversampling, Normal mode

  write_i2c(BME280_CTRL_MEAS_REGISTER, ctrlSettings);
  write_i2c(BME280_CONFIG_REGISTER, 0x60);		// 250ms sampling rate, no IIR filter 
}


static uint8_t checkBME280ID(void)
{
  uint8_t data = 0;
  uint8_t retVal = 1;

  data = read_i2c(BME280_ID_REGISTER);
  
  if(data != BME280_DEVICE_ID)
  {
    retVal = 0;
  }

  return retVal;
}

int32_t getBME280Temperature(void)
{
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

  return comp_temp_reading;
}

void main(void)
{
  int32_t temperature;

  if(1 != checkBME280ID())
  {
    printf("Error, ID not equal to expected BME280 of %d!\r\n", BME280_DEVICE_ID);
    while(1);
  }

  getTempCalibrationParameters();
  setBME280Config();
  
  while (1)
  {
    temperature = getBME280Temperature();
    printf("{\"topic\":\"sensor\",\"message\":\"{\\\"temperature\\\":%h}\"}",temperature);
    putchar(0x04);
  }
}

