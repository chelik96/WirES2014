#include <xc.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <plib/spi.h>
#include <plib/delays.h>
#include <plib/usart.h>
#include <plib/timers.h>
#include <plib/adc.h>
#include "MRF24J40.h"

#pragma config OSC     = HS
#pragma config FCMEN   = OFF
#pragma config IESO    = OFF
#pragma config PWRT    = OFF
#pragma config BOREN   = SBORDIS
#pragma config BORV    = 3
#pragma config WDT     = OFF
#pragma config WDTPS   = 32768
#pragma config CCP2MX  = PORTC
#pragma config PBADEN  = ON
#pragma config LPT1OSC = OFF
#pragma config MCLRE   = ON
#pragma config STVREN  = ON
#pragma config LVP     = OFF
#pragma config XINST   = OFF
#pragma config CP0     = OFF
#pragma config CP1     = OFF
#pragma config CP2     = OFF
#pragma config CP3     = OFF
#pragma config CPB     = OFF
#pragma config CPD     = OFF
#pragma config WRT0    = OFF
#pragma config WRT1    = OFF
#pragma config WRT2    = OFF
#pragma config WRT3    = OFF
#pragma config WRTC    = OFF
#pragma config WRTB    = OFF
#pragma config WRTD    = OFF
#pragma config EBTR0   = OFF
#pragma config EBTR1   = OFF
#pragma config EBTR2   = OFF
#pragma config EBTR3   = OFF
#pragma config EBTRB   = OFF

#define NODES 4
#define GROUPID 23
#define NODEID 1

typedef struct {
    unsigned char GroupID;
    unsigned char NodeID;
    unsigned char Temp;
    unsigned char Light;
    unsigned int  CRC;
} PacketType;

typedef struct {
    unsigned char Temp;
    unsigned char Light;
    unsigned char Strength;
} ReadingType[4];

void Init_IO(void) {
    PORTA             = 0x04;
    TRISA             = 0xF8;
    TRISB             = 0xFF;
    INTCON2bits.RBPU  = 0;
    PORTCbits.RC0     = 1;
    TRISCbits.TRISC0  = 0;
    PORTCbits.RC1     = 1;
    TRISCbits.TRISC0  = 0;
    PORTCbits.RC2     = 1;
    TRISCbits.TRISC2  = 0;
    ADCON0            = 0x1C;
    INTCONbits.INT0IF = 0;
    INTCONbits.INT0IE = 1;
    RCONbits.IPEN     = 1;
    INTCONbits.GIEH   = 1;
    OSCCONbits.IDLEN  = 1;
    OpenSPI(SPI_FOSC_4,MODE_00,SMPMID);
    OpenUSART(USART_TX_INT_OFF & USART_RX_INT_OFF & USART_ASYNCH_MODE &
              USART_EIGHT_BIT & USART_CONT_RX & USART_BRGH_HIGH,25);
}

void USARTOut(char *data, char bytes) {
    int i;
    for(i=0; i<bytes; i++) {
        while(BusyUSART());
        WriteUSART(data[i]);
    }
}

unsigned char getTemp();
unsigned char getLight();
unsigned int  getCRC(PacketType packet);

PacketType TxPacket,RxPacket;

char Text[128];
unsigned char Counter = 0;
unsigned char Strength = 0;
char config        = ADC_FOSC_16 & ADC_RIGHT_JUST & ADC_16_TAD;
char config2_temp  = ADC_CH6 & ADC_INT_ON & ADC_VREFPLUS_VDD & ADC_VREFMINUS_VSS;
char config2_light = ADC_CH5 & ADC_INT_ON & ADC_VREFPLUS_VDD & ADC_VREFMINUS_VSS;
char portconfig    = 7;
unsigned int tCRC = 0;
unsigned int gCRC = 0;

unsigned int CurrentWindow = 0;
ReadingType readings;

void main (void) {
   
    Init_IO();
    MRF24J40Init();
    
    // Initialize readings array (must be better way to write this...
    readings[0].Temp = 0;
    readings[1].Temp = 0;
    readings[2].Temp = 0;
    readings[3].Temp = 0;
    readings[0].Light = 0;
    readings[1].Light = 0;
    readings[2].Light = 0;
    readings[3].Light = 0;
    readings[0].Strength = 0;
    readings[1].Strength = 0;
    readings[2].Strength = 0;
    readings[3].Strength = 0;


    SetChannel(CHANNEL_17);
    // Use Timer 0 to send out this nodes reading over RF
    OpenTimer0( TIMER_INT_ON & T0_16BIT & T0_SOURCE_INT & T0_PS_1_4);
    //Use Timer 1 to print out most up-to-date received readings
    //OpenTimer1( TIMER_INT_ON & T1_SOURCE_INT & T1_PS_1_8);

    while(1) {
	if(INTCONbits.TMR0IF) {
            INTCONbits.TMR0IF = 0; // Clear Timer Interrupt Flag
            // Loop through the windows each time the timer interrupts
            if (CurrentWindow != 0) CurrentWindow = (CurrentWindow % NODES) + 1;

            // Setup transmission
            TxPacket.GroupID = GROUPID;
            TxPacket.NodeID  = NODEID;
            TxPacket.Temp    = getTemp();
            TxPacket.Light   = getLight();
            TxPacket.CRC     = 0;
            //TxPacket.CRC     = getCRC(TxPacket);
            Strength = PHYGetRSSI();

            //Add Own data to readings
            readings[NODEID - 1].Temp = TxPacket.Temp;
            readings[NODEID - 1].Light = TxPacket.Light;
            readings[NODEID - 1].Strength = Strength;

            PORTA = 0x05;
            
            // if we are the master node and we haven't then just send,
            // otherwise wait until the appropriate window for our NodeID
            if (NODEID == 1 & CurrentWindow == 0) {
              PHYTransmit((char *)&TxPacket,sizeof(PacketType));
              CurrentWindow = NODEID;
            } else if (CurrentWindow == NODEID) {
                PHYTransmit((char *)&TxPacket,sizeof(PacketType));
            }
            PORTA = 0x04;

        }
	if(PHYReceive((char *)&RxPacket,&Strength) == sizeof(PacketType)) {
            // Don't Start Counting Windows until the master sends a packet.
            if (RxPacket.NodeID == 1) CurrentWindow = 1;
            PORTA = 0x05;
            tCRC = RxPacket.CRC;  // transmitted CRC value
            RxPacket.CRC = 0;
            //gCRC = getCRC(RxPacket);  // generated CRC value

            // if data CRC OK, store the data
            //if (tCRC == gCRC) {
            //    if (RxPacket.GroupID == GROUPID)  {
            //        readings[RxPacket.NodeID].Temp = RxPacket.Temp;
            //        readings[RxPacket.NodeID].Light = RxPacket.Light;
            //        readings[RxPacket.NodeID].Strength = Strength;
            //    }
            //}
            PORTA = 0x04;
            sprintf(Text,"Testing\n");
            USARTOut(Text,strlen(Text));
        }
        /*/if (PIR1bits.TMR1IF) {
            PIR1bits.TMR1IF = 0; // Clear Timer Interrupt Flag
            PORTA = 0x04;
            // Output latest data to terminal once a second
            //sprintf(Text,"N1: T%u L%u S%u\nN2: T%u L%u S%u\nN3: T%u L%u S%u\nN4: T%u L%u S%u\n",
            //  readings[0].Temp, readings[0].Light, readings[0].Strength,
            //  readings[1].Temp, readings[1].Light, readings[1].Strength,
            //  readings[2].Temp, readings[2].Light, readings[2].Strength,
            //  readings[3].Temp, readings[3].Light, readings[3].Strength);

            PORTA = 0x06;
        }*/
    Sleep();
    }
}

// Get Temperature Sensor Resistance Value
unsigned char getTemp() {
    unsigned char temp = 0;
    OpenADC(config, config2_temp, portconfig);
    Delay10TCYx(5);
    ConvertADC();
    while(BusyADC());
    temp = ReadADC();
    // conversion - massively simplified version for testing
    temp = 158 - temp;
    CloseADC();
    return temp;
}

// Get Light Sensor Resistance Value
unsigned char getLight() {
    unsigned char light = 0;
    OpenADC(config, config2_light, portconfig);
    Delay10TCYx(5);
    ConvertADC();
    while (BusyADC());
    light = ReadADC();
    // conversion - massively simplified version for testing
  /*  if (light < 80) {
        light = 0;
    } else if (light > 150) {
        light = 2;
    } else {
        light = 1;
    }*/
    CloseADC();
    return light;
}

unsigned int getCRC(PacketType packet) {
    // we use the XMODEM poly (0x8408) to generate the CRC
    unsigned short crc_tbl[16] = {
        0x0000, 0x1E3D, 0x1C39, 0x0204, 0x1831, 0x060C, 0x0408, 0x1A35,
        0x1021, 0x0E1C, 0x0C18, 0x1225, 0x0810, 0x162D, 0x1429, 0x0A14,
    };
    unsigned int i, ch;
    unsigned int acc = 0xFFFF;
    int *rawPacket = (int*)&packet;
    // Nibble-at-a-time processing. Reflected algorithm; lo-nibble first.
    for (i=0; i <= sizeof(&rawPacket); i++) {
        ch = rawPacket[i];
        acc = crc_tbl[(ch ^ acc) & 15] ^ (acc >> 4);
        acc = crc_tbl[((ch >> 4) ^ acc) & 15] ^ (acc >> 4);
    }
    return acc;
}