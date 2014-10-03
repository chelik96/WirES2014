//****************************************************************
//**** Stub program for PICDEM-Z board using MRF24J40  		******
//**** Jeff Neasham 15/09/2009								******
//**** MAY BE ALTERED BY STUDENTS							******
//****************************************************************

// PIC18F4620 Configuration Bit Settings

#include <xc.h>

// CONFIG1H
#pragma config OSC = HS         // Oscillator Selection bits (HS oscillator)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
#pragma config IESO = OFF       // Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

// CONFIG2L
#pragma config PWRT = OFF       // Power-up Timer Enable bit (PWRT disabled)
#pragma config BOREN = SBORDIS  // Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
#pragma config BORV = 3         // Brown Out Reset Voltage bits (Minimum setting)

// CONFIG2H
#pragma config WDT = OFF        // Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
#pragma config WDTPS = 32768    // Watchdog Timer Postscale Select bits (1:32768)

// CONFIG3H
#pragma config CCP2MX = PORTC   // CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
#pragma config PBADEN = ON      // PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
#pragma config LPT1OSC = OFF    // Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
#pragma config MCLRE = ON       // MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

// CONFIG4L
#pragma config STVREN = ON      // Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
#pragma config LVP = OFF        // Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
#pragma config XINST = OFF      // Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

// CONFIG5L
#pragma config CP0 = OFF        // Code Protection bit (Block 0 (000800-003FFFh) not code-protected)
#pragma config CP1 = OFF        // Code Protection bit (Block 1 (004000-007FFFh) not code-protected)
#pragma config CP2 = OFF        // Code Protection bit (Block 2 (008000-00BFFFh) not code-protected)
#pragma config CP3 = OFF        // Code Protection bit (Block 3 (00C000-00FFFFh) not code-protected)

// CONFIG5H
#pragma config CPB = OFF        // Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
#pragma config CPD = OFF        // Data EEPROM Code Protection bit (Data EEPROM not code-protected)

// CONFIG6L
#pragma config WRT0 = OFF       // Write Protection bit (Block 0 (000800-003FFFh) not write-protected)
#pragma config WRT1 = OFF       // Write Protection bit (Block 1 (004000-007FFFh) not write-protected)
#pragma config WRT2 = OFF       // Write Protection bit (Block 2 (008000-00BFFFh) not write-protected)
#pragma config WRT3 = OFF       // Write Protection bit (Block 3 (00C000-00FFFFh) not write-protected)

// CONFIG6H
#pragma config WRTC = OFF       // Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
#pragma config WRTB = OFF       // Boot Block Write Protection bit (Boot Block (000000-0007FFh) not write-protected)
#pragma config WRTD = OFF       // Data EEPROM Write Protection bit (Data EEPROM not write-protected)

// CONFIG7L
#pragma config EBTR0 = OFF      // Table Read Protection bit (Block 0 (000800-003FFFh) not protected from table reads executed in other blocks)
#pragma config EBTR1 = OFF      // Table Read Protection bit (Block 1 (004000-007FFFh) not protected from table reads executed in other blocks)
#pragma config EBTR2 = OFF      // Table Read Protection bit (Block 2 (008000-00BFFFh) not protected from table reads executed in other blocks)
#pragma config EBTR3 = OFF      // Table Read Protection bit (Block 3 (00C000-00FFFFh) not protected from table reads executed in other blocks)

// CONFIG7H
#pragma config EBTRB = OFF      // Boot Block Table Read Protection bit (Boot Block (000000-0007FFh) not protected from table reads executed in other blocks)


#include <stdlib.h>			//standard library
#include <stdio.h>
#include <plib/spi.h>			//serial peripheral interface functions
#include <plib/delays.h>		//time delay functions
#include <plib/usart.h>			//USART functions
#include <string.h>			//string functions
#include <plib/timers.h>		//timer functions

#include "MRF24J40.h"		//driver function definitions for MRF24J40 RF transceiver

//**************************************************************************
//** Function to initialise all I/O resources used by Processor ************
//*** THIS MAY BE MODIFIED AND EXPANDED WITH STUDENTS' CODE	    ********
//**************************************************************************

void Init_IO(void)
{
	PORTA = 0x04;							//PORTA initially all zeros except RA2 (TC77 chip select)
	TRISA = 0xF8;							//RA0 and RA1 outputs (LEDs), RA2 Output (TC77 CS), rest inputs
	TRISB = 0xFF;							//PORTB all inputs (RB0 is interrupt, RB4 and RB5 are push buttons)
	INTCON2bits.RBPU = 0;					//enable pull up resistors on PORTB
	PORTCbits.RC0 = 1; 						//Chip select (/CS) initially set high (MRF24J40)
	TRISCbits.TRISC0 = 0; 					//Output: /CS
	PORTCbits.RC1 = 1; 						//WAKE initially set high (MRF24J40)
	TRISCbits.TRISC0 = 0; 					//Output: WAKE
	PORTCbits.RC2 = 1; 						//RESETn initially set high (MRF24J40)
	TRISCbits.TRISC2 = 0;					//output: RESETn
	ADCON0 = 0x1C; 							//turn off analog input

	INTCONbits.INT0IF = 0;              	//clear the interrupt flag (INT0 = RB0)
    INTCONbits.INT0IE = 1;					//enable INT0
  	RCONbits.IPEN = 1;						//enable interrupt priorities
    INTCONbits.GIEH = 1;					//global interrupt enable
	OSCCONbits.IDLEN = 1;					//enable idle mode (when Sleep() is executed)
	
	OpenSPI(SPI_FOSC_4,MODE_00,SMPMID);		//setup SPI bus (SPI mode 00, 1MHz SCLK) (MRF24J40)
	OpenUSART(USART_TX_INT_OFF & USART_RX_INT_OFF & USART_ASYNCH_MODE &
			  USART_EIGHT_BIT & USART_CONT_RX & USART_BRGH_HIGH,25 );	//setup USART @ 9600 Baud
}

//**************************************************************************
//** Function to output an array of bytes to the USART (RS232 port) ********
//** MUST NOT BE CHANGED BY STUDENTS                            	********
//**************************************************************************

void USARTOut(char *data, char bytes)
{
	int i;
	for(i=0; i<bytes; i++)
		{
		while(BusyUSART());
		WriteUSART(data[i]);
		}
}

//**************************************************************************
//** Example of simple data packet structure                   		********
//**************************************************************************

typedef struct 
	{
	unsigned char ID;			//unique identifier
	unsigned char Data;			//data byte
	} 
	PacketType;

//**************************************************************************
//** Global Variables 												********
//**************************************************************************
	
PacketType TxPacket,RxPacket;			//transmitted and received packets
char Text[128];							//buffer for temporary strings
unsigned char Counter=0,Strength;		//other variables used in main function	

//**************************************************************************
//*** MAIN function of program - transmits or receives text message	********
//*** THIS WILL BE MODIFIED AND EXPANDED WITH STUDENTS' CODE	    ********
//**************************************************************************

void main (void)
{
Init_IO();					//initialise all processor I/O resources used by the program
MRF24J40Init();				//initialise IEEE 802.15.4 transceiver
SetChannel(CHANNEL_11);		//set RF channel CHANNEL_11-CHANNEL_26 (EACH GROUP MUST HAVE UNIQUE CHANNEL)
OpenTimer0( TIMER_INT_ON & T0_16BIT & T0_SOURCE_INT & T0_PS_1_8);		//setup timer 0 with prescaler x8

while(1)											//infinite loop
	{
	if(INTCONbits.TMR0IF)							//if interrupt came from timer then transmit data packet
		{
		INTCONbits.TMR0IF = 0;						//clear timer interrupt
		TxPacket.ID = 1;							//set ID byte (e.g. group number)
		TxPacket.Data = Counter++;					//fill data with incrementing counter value
		PORTA = 0x05;								//switch on LED 0 (must keep RA3 high)
		//Strength = PHYGetRSSI();					//get signal strength (can be used to check if channel clear)
		PHYTransmit((char *)&TxPacket,sizeof(PacketType));	//Transmit RF data packet 
		PORTA = 0x04;								//switch off LED 0 (must keep RA3 high)
		}
	if(PHYReceive((char *)&RxPacket,&Strength) == sizeof(PacketType)) //check for received RF packet and validate size 
		{
		PORTA = 0x06;								//switch on LED 1 (must keep RA3 high)
		sprintf(Text,"ID = %u Data = %u RSSI = %u\r\n",
			RxPacket.ID,RxPacket.Data,Strength);	//format ID, data and RSSI as ASCII string for output to terminal
		USARTOut(Text,strlen(Text));				//output string to USART
		PORTA = 0x04;								//switch off LED 1 (must keep RA3 high)
		}
	Sleep();										//put processor into idle mode and wait for interrupt from timer or transceiver
	} 
}
