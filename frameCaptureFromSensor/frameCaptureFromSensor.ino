// Import libraries
#include <SPI.h>
#include <avr/pgmspace.h>
#include <clockwork.h>

const int ncs = 51;
const int mot = 53;

// Registers
#define REG_Product_ID                           0x00
#define REG_Revision_ID                          0x01
#define REG_Motion                               0x02
#define REG_Delta_X_L                            0x03
#define REG_Delta_X_H                            0x04
#define REG_Delta_Y_L                            0x05
#define REG_Delta_Y_H                            0x06
#define REG_SQUAL                                0x07
#define REG_Pixel_Sum                            0x08
#define REG_Maximum_Pixel                        0x09
#define REG_Minimum_Pixel                        0x0a
#define REG_Shutter_Lower                        0x0b
#define REG_Shutter_Upper                        0x0c
#define REG_Frame_Period_Lower                   0x0d
#define REG_Frame_Period_Upper                   0x0e
#define REG_Configuration_I                      0x0f
#define REG_Configuration_II                     0x10
#define REG_Frame_Capture                        0x12
#define REG_SROM_Enable                          0x13
#define REG_Run_Downshift                        0x14
#define REG_Rest1_Rate                           0x15
#define REG_Rest1_Downshift                      0x16
#define REG_Rest2_Rate                           0x17
#define REG_Rest2_Downshift                      0x18
#define REG_Rest3_Rate                           0x19
#define REG_Frame_Period_Max_Bound_Lower         0x1a
#define REG_Frame_Period_Max_Bound_Upper         0x1b
#define REG_Frame_Period_Min_Bound_Lower         0x1c
#define REG_Frame_Period_Min_Bound_Upper         0x1d
#define REG_Shutter_Max_Bound_Lower              0x1e
#define REG_Shutter_Max_Bound_Upper              0x1f
#define REG_LASER_CTRL0                          0x20
#define REG_Observation                          0x24
#define REG_Data_Out_Lower                       0x25
#define REG_Data_Out_Upper                       0x26
#define REG_SROM_ID                              0x2a
#define REG_Lift_Detection_Thr                   0x2e
#define REG_Configuration_V                      0x2f
#define REG_Configuration_IV                     0x39
#define REG_Power_Up_Reset                       0x3a
#define REG_Shutdown                             0x3b
#define REG_Inverse_Product_ID                   0x3f
#define REG_Motion_Burst                         0x50
#define REG_SROM_Load_Burst                      0x62
#define REG_Pixel_Burst                          0x64

#define PIXELS_IN_FRAME                          900
byte frame[PIXELS_IN_FRAME];
extern const unsigned short firmware_length;
extern const unsigned char firmware_data[];

void setup() {
  Serial.begin(9600);
    
  pinMode (ncs, OUTPUT);
  pinMode (mot, INPUT);


  SPI.begin();
  SPI.setDataMode(SPI_MODE3);
  SPI.setBitOrder(MSBFIRST);
  //SPI.setClockDivider(42);
  SPI.setClockDivider(64);

  performStartup();
  init_for_frame_capture_mode();
  delay(5000);
}

void adns_com_begin() {
  digitalWrite(ncs, LOW);
}

void adns_com_end() {
  digitalWrite(ncs, HIGH);
}

byte adns_read_reg(byte reg_addr, bool last=true) {
  adns_com_begin();

  // send adress of the register, with MSBit = 0 to indicate it's a read
  SPI.transfer(reg_addr & 0x7f );
  delayMicroseconds(100); // tSRAD
  // read data
  byte data = SPI.transfer(0);

  if (last) {
    delayMicroseconds(1); // tSCLK-NCS for read operation is 120ns
    adns_com_end();
    delayMicroseconds(19); //  tSRW/tSRR (=20us) minus tSCLK-NCS
  }
  
  return data;
}

void adns_write_reg(byte reg_addr, byte data, bool last=true) {
  adns_com_begin();

  //send adress of the register, with MSBit = 1 to indicate it's a write
  SPI.transfer(reg_addr | 0x80 );
  //sent data
  SPI.transfer(data);

  if(last) {
    delayMicroseconds(20); // tSCLK-NCS for write operation
    adns_com_end();
    delayMicroseconds(100); // tSWW/tSWR (=120us) minus tSCLK-NCS. Could be shortened, but is looks like a safe lower bound
  }
}

void adns_upload_firmware() {
  // send the firmware to the chip, cf p.18 of the datasheet
  ////////Serial.println("Uploading firmware...");
  // set the configuration_IV register in 3k firmware mode
  adns_write_reg(REG_Configuration_IV, 0x02); // bit 1 = 1 for 3k mode, other bits are reserved

  // write 0x1d in SROM_enable reg for initializing
  adns_write_reg(REG_SROM_Enable, 0x1d);

  // wait for more than one frame period
  delay(10); // assume that the frame rate is as low as 100fps... even if it should never be that low

  // write 0x18 to SROM_enable to start SROM download
  adns_write_reg(REG_SROM_Enable, 0x18);

  // write the SROM file (=firmware data)
  adns_com_begin();
  SPI.transfer(REG_SROM_Load_Burst | 0x80); // write burst destination adress
  delayMicroseconds(15);

  // send all bytes of the firmware
  unsigned char c;
  for (int i = 0; i < firmware_length; i++) {
    c = (unsigned char)pgm_read_byte(firmware_data + i);
    SPI.transfer(c);
    delayMicroseconds(15);
  }
  adns_com_end();
}

void init_for_frame_capture_mode(void) {
  //  1. Reset the chip by writing 0x5a to Power_Up_Reset register (address 0x3a).

  ////Serial.println("; Step 1.");

  adns_write_reg(REG_Power_Up_Reset, 0x5a); // force reset

  delay(50); // wait for it to reboot

  //  2. Enable laser by setting Forced_Disable bit (Bit-0) of LASER_CTRL) register to 0.

  ////Serial.println("; Step 2.");

  //enable laser(bit 0 = 0b), in normal mode (bits 3,2,1 = 000b)
  // reading the actual value of the register is important because the real
  // default value is different from what is said in the datasheet, and if you
  // change the reserved bytes (like by writing 0x00...) it would not work.
  byte laser_ctrl0 = adns_read_reg(REG_LASER_CTRL0);
  // adns_write_reg(REG_LASER_CTRL0, laser_ctrl0 & 0xf0);
  adns_write_reg(REG_LASER_CTRL0, laser_ctrl0 & 0xf1); // Turn laser off

  delay(1);
}

void performStartup(void) {
  adns_com_end(); // ensure that the serial port is reset
  adns_com_begin(); // ensure that the serial port is reset
  adns_com_end(); // ensure that the serial port is reset
  adns_write_reg(REG_Power_Up_Reset, 0x5a); // force reset
  delay(50); // wait for it to reboot
  // read registers 0x02 to 0x06 (and discard the data)
  adns_read_reg(REG_Motion);
  adns_read_reg(REG_Delta_X_L);
  adns_read_reg(REG_Delta_X_H);
  adns_read_reg(REG_Delta_Y_L);
  adns_read_reg(REG_Delta_Y_H);
  // upload the firmware
  adns_upload_firmware();
  delay(10);
  //enable laser(bit 0 = 0b), in normal mode (bits 3,2,1 = 000b)
  // reading the actual value of the register is important because the real
  // default value is different from what is said in the datasheet, and if you
  // change the reserved bytes (like by writing 0x00...) it would not work.
  byte laser_ctrl0 = adns_read_reg(REG_LASER_CTRL0);
  adns_write_reg(REG_LASER_CTRL0, laser_ctrl0 & 0xf0 );

  delay(1);

  //////Serial.println("Optical Chip Initialized");
}

void read_frame_from_sensor(void) {

  //Serial.println("About to read frame from sensor");
  
  adns_write_reg(REG_Frame_Capture, 0x93); // frame capture
  adns_write_reg(REG_Frame_Capture, 0xc5); // frame capture

  delay(20);

  // Check that the frame is ready
  byte firstByte;

  do {
    firstByte = adns_read_reg(REG_Motion, false);
  } while ((firstByte & 1) == 0);

  delayMicroseconds(100);

  //Serial.println("Frame pixels are ready");  
  
  // Read the frame
  SPI.transfer(REG_Pixel_Burst);
  delayMicroseconds(100); // tSRAD

  for (int i = 0; i < PIXELS_IN_FRAME; i++) {
    frame[i] = SPI.transfer(0);
    delayMicroseconds(15);
  }

  adns_com_end();
}

void write_frame_to_serial(void)
{
  
  byte go_ahead_signal_from_client = Serial.read();
  byte header = 15;
  Serial.write(header);
  Serial.write(frame, PIXELS_IN_FRAME);

#if 0
  //Serial.println("Writing a header");
  int i=0;
  while( i < PIXELS_IN_FRAME )
  {
   //Serial.print(frame[i]);
   if ((i % 30) == 0 )
   {
     //Serial.print("\n");
   }
   else
   {
      //Serial.print(" ");
   }
   
   i = i + 1;
  }
#endif
}

void tet_warning(long t) {
  //Serial.print(t);
  //Serial.println(" TET warning!");
}

Clockwork cw(100, tet_warning);

void loop()
{
  //cw.start();
  read_frame_from_sensor();
  write_frame_to_serial();  
  //cw.stop();
}


