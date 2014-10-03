//************************************************************
//**** Stub program for PICDEM-Z board using MRF24J40  	******
//**** Jeff Neasham 15/09/2009				******
//**** MAY BE ALTERED BY STUDENTS			******
//************************************************************
#include <xc.h>
#include <stdlib.h> //standard library
#include <stdio.h>
#include <plib/spi.h> //serial peripheral interface functions
#include <plib/delays.h> //time delay functions
#include <plib/usart.h> //USART functions
#include <string.h> //string functions
#include <plib/timers.h> //timer functions
#include <plib/adc.h> // Analog to Digital Converter functions
#include "picconfig.h" // Removed Defines from main program
#include "MRF24J40.h" //driver function definitions for MRF24J40 RF transceiver

#define NUMNODES 4
//******************************************************************************
// Constants
const unsigned char ThisNode = 2; // Change when compiling for each node (1,2,3,4)
const unsigned char NumNodes = NUMNODES;
const unsigned char OurGroup = 23;
const unsigned char OurChann = CHANNEL_17;

const unsigned int  OneSecDelay = 3035;

enum protocol {None, TDMA, CSMA};
const unsigned int  OurProto = TDMA;

enum light {Bright, Normal, Null, Shadow};
const char *lightstr[] = {"Bright\0","Normal\0","Nullch\0","Shadow\0"};

//******************************************************************************

//**************************************************************************
//** Function to initialise all I/O resources used by Processor ************
//*** THIS MAY BE MODIFIED AND EXPANDED WITH STUDENTS' CODE	    ********
//**************************************************************************
void Init_IO(void) {
    PORTA = 0x04; //PORTA initially all zeros except RA2 (TC77 chip select)
    TRISA = 0xF8; //RA0 and RA1 outputs (LEDs), RA2 Output (TC77 CS), rest inputs
    TRISB = 0xFF; //PORTB all inputs (RB0 is interrupt, RB4 and RB5 are push buttons)
    INTCON2bits.RBPU = 0; //enable pull up resistors on PORTB
    PORTCbits.RC0 = 1; //Chip select (/CS) initially set high (MRF24J40)
    TRISCbits.TRISC0 = 0; //Output: /CS
    PORTCbits.RC1 = 1; //WAKE initially set high (MRF24J40)
    TRISCbits.TRISC0 = 0; //Output: WAKE
    PORTCbits.RC2 = 1; //RESETn initially set high (MRF24J40)
    TRISCbits.TRISC2 = 0; //output: RESETn
    ADCON0 = 0x1C; //turn off analog input

    // timer 0 setting
    INTCONbits.INT0IF = 0; //clear the interrupt flag (INT0 = RB0)
    INTCONbits.INT0IE = 1; //enable INT0
    // timer 1 settings
    PIR1bits.TMR1IF = 0;
    PIE1bits.TMR1IE = 1;

    RCONbits.IPEN = 1; //enable interrupt priorities
    INTCONbits.GIEH = 1; //global interrupt enable
    OSCCONbits.IDLEN = 1; //enable idle mode (when Sleep() is executed)

    OpenSPI(SPI_FOSC_4,MODE_00,SMPMID); //setup SPI bus (SPI mode 00, 1MHz SCLK) (MRF24J40)
    OpenUSART(USART_TX_INT_OFF & USART_RX_INT_OFF & USART_ASYNCH_MODE &
			  USART_EIGHT_BIT & USART_CONT_RX & USART_BRGH_HIGH,25 ); //setup USART @ 9600 Baud
}
//**************************************************************************
//** Function to output an array of bytes to the USART (RS232 port) ********
//** MUST NOT BE CHANGED BY STUDENTS                                ********
//**************************************************************************
void USARTOut(char *data, char bytes) {
    int i;
    for(i=0; i<bytes; i++) {
        while(BusyUSART());
        WriteUSART(data[i]);
    }
}

//**************************************************************************
//** Example of simple data packet structure                        ********
//**************************************************************************
typedef struct {
    unsigned char GroupID; // Group Number (should be 23)
    unsigned char NodeID;  // Unique Identifier for this device
    unsigned char Temp;    // Reading on the thermistor
    unsigned char Light;   // Reading on the light sensor
    unsigned int  CRC;     // Cyclic Redundancy Check
    unsigned char Strength;// Keep record of how strong received signal was
} PacketType;

//**************************************************************************
//** Global Variables                                               ********
//**************************************************************************
PacketType TxPacket,RxPacket; //transmitted and received packets
PacketType SvPacket[NUMNODES]; // Storage for received packets
char Text[128]; //buffer for temporary strings
unsigned char Strength;
unsigned char LastReceived = 0;
unsigned char WaitCounter = 0;
unsigned char ActiveNode[NUMNODES];
// Sub Function Declarations (see beneath main for implementation)
void SetupPacket();
void SendPacket();
unsigned char ReceivePacket();
void TerminalOut();
void InitDataStore();
void NoneLoop();
void TDMALoop();
char TDMAReady();
void CSMALoop();
char CSMAReady();
void CSMAWaitRandom();
void ResetActiveNodes();
unsigned char getTemp();
unsigned char getLight();
unsigned int  getCRC(PacketType packet);

//**************************************************************************
//*** MAIN function of program - transmits or receives text message ********
//*** THIS WILL BE MODIFIED AND EXPANDED WITH STUDENTS' CODE	    ********
//**************************************************************************
void main (void) {
    Init_IO(); //initialise all processor I/O resources used by the program
    MRF24J40Init(); //initialise IEEE 802.15.4 transceiver
    SetChannel(OurChann); //set RF channel CHANNEL_11-CHANNEL_26 (EACH GROUP MUST HAVE UNIQUE CHANNEL)

    // Intialise Timers
    OpenTimer0( TIMER_INT_ON & T0_16BIT & T0_SOURCE_INT & T0_PS_1_16); //setup timer 0 with prescaler x8
    OpenTimer1( TIMER_INT_ON & T1_16BIT_RW & T1_SOURCE_INT & T1_PS_1_1 & T1_OSC1EN_OFF & T1_SYNC_EXT_OFF);
    InitDataStore();

    switch (OurProto) {
        case TDMA: TDMALoop();
        case CSMA: CSMALoop();
        default: NoneLoop();
    }
}

void InitDataStore() {
    char i;
    for (i=0;i<NumNodes;i++) {
        SvPacket[i].GroupID = 23;
        SvPacket[i].NodeID  = i + 1;
    }
}

void NoneLoop() {
    while(1) { //infinite loop
        if (INTCONbits.TMR0IF) {
            INTCONbits.TMR0IF = 0;
            WriteTimer1(OneSecDelay);
            TerminalOut();
        }
        if (PIR1bits.TMR1IF) {
            PIR1bits.TMR1IF = 0;
            SetupPacket();
            SendPacket();
        }
        if (PHYReceive((char *)&RxPacket,&Strength) == sizeof(PacketType)) { //check for received RF packet and validate size
            ReceivePacket();
        }
        Sleep(); //put processor into idle mode and wait for interrupt
    }
}

void TDMALoop() {
    ResetActiveNodes();
    while(1) { //infinite loop
        if (INTCONbits.TMR0IF) {
            INTCONbits.TMR0IF = 0;
            WriteTimer1(OneSecDelay);
            TerminalOut();
        }
        if (PIR1bits.TMR1IF) {
            PIR1bits.TMR1IF = 0;
            SetupPacket();
            if (TDMAReady) SendPacket();
        }
        if (PHYReceive((char *)&RxPacket,&Strength) == sizeof(PacketType)) { //check for received RF packet and validate size
            LastReceived = ReceivePacket();
            if (ActiveNode[LastReceived - 1] == 0) ActiveNode[LastReceived - 1] = 1;
        }
        Sleep(); //put processor into idle mode and wait for interrupt
    }
}

void CSMALoop() {
    srand(ThisNode);
    ResetActiveNodes();
    while(1) { //infinite loop
        if (INTCONbits.TMR0IF) {
            INTCONbits.TMR0IF = 0;
            WriteTimer1(OneSecDelay);
            TerminalOut();
        }
        if (PIR1bits.TMR1IF) {
            PIR1bits.TMR1IF = 0;
            if (CSMAReady()) { // Wait one cycle (Total Nodes * Time Slot Duration)
                SetupPacket();
                Strength = PHYGetRSSI();
                // if channel is free send the packet
                if (Strength < 10) {
                    SendPacket();
                } else {
                    CSMAWaitRandom();
                }
            }
        }
        if (PHYReceive((char *)&RxPacket,&Strength) == sizeof(PacketType)) { //check for received RF packet and validate size
            LastReceived = ReceivePacket();
            if (ActiveNode[LastReceived - 1] == 0) ActiveNode[LastReceived - 1] = 1;
        }
        Sleep(); //put processor into idle mode and wait for interrupt
    }
}

void SetupPacket() {
    SvPacket[ThisNode - 1].GroupID = OurGroup; //set ID byte (e.g. group number)
    SvPacket[ThisNode - 1].NodeID  = ThisNode;
    SvPacket[ThisNode - 1].Temp    = getTemp();
    SvPacket[ThisNode - 1].Light   = getLight();
    SvPacket[ThisNode - 1].CRC     = 0; // Need to generate CRC against..
    SvPacket[ThisNode - 1].Strength= 0; //..a packet with known values first
    SvPacket[ThisNode - 1].CRC     = getCRC(SvPacket[ThisNode -1]);
    TxPacket = SvPacket[ThisNode - 1]; // save this nodes currentdata ready for transmit
}

char TDMAReady() {
    // ready if just received new packet from previous node,...
    // or time out if you've waited for enough time for all nodes to send...
    // otherwise keep waiting...
    if ((LastReceived % NumNodes) == (ThisNode - 1)){
        WaitCounter = 0;
        return 1;
    } else if (WaitCounter >= NumNodes) {
        WaitCounter = 0;
        return 1;
    } else {
        WaitCounter = WaitCounter++;
        return 0;
    }
}

char CSMAReady() {
    // ready to try to send again if enough time has passed for all nodes to send once...
    // otherwise keep waiting...
    if (WaitCounter >= NumNodes) {
        WaitCounter = 0;
        return 1;
    } else {
        WaitCounter = WaitCounter++;
        return 0;
    }
}

void CSMAWaitRandom() {
    WaitCounter = rand() % NumNodes;
}

void SendPacket() {
    PORTA = 0x05; //switch on LED 0 (must keep RA3 high)
    PHYTransmit((char *)&TxPacket,sizeof(PacketType)); //Transmit RF data packet
    PORTA = 0x04; //switch off LED 0 (must keep RA3 high)
}

void ResetActiveNodes() {
    char i;
    ActiveNode[ThisNode -1] = 1;
    for (i=0;i<NumNodes;i++) {
        if (i != ThisNode - 1) ActiveNode[i] = 0;
    }
}

unsigned char ReceivePacket() {
    unsigned int tCRC,gCRC;
    unsigned char receivedfrom = 0;
    PORTA = 0x06; //switch on LED 1 (must keep RA3 high)
    tCRC = RxPacket.CRC;  // store the transmitted CRC value
    RxPacket.CRC = 0; // Generate CRC vaule against packet with known CRC value
    gCRC = getCRC(RxPacket);  // generate a CRC value
    if (tCRC == gCRC) { // compare generated and stored CRC, only submit data if same
        SvPacket[RxPacket.NodeID - 1] = RxPacket;
        SvPacket[RxPacket.NodeID - 1].Strength = Strength; // Store received strenght value
        receivedfrom = RxPacket.NodeID;
    }
    PORTA = 0x04; //switch off LED 1 (must keep RA3 high)
    return receivedfrom;
}

void TerminalOut() {
    char Text[128];
    char Data[128];
    int i;
    char degreesymbol = 176;
    for (i=0;i<NumNodes;i++) {
        if (SvPacket[i].GroupID == OurGroup) { // Only output info from working nodes
            sprintf(Text,"GroupID = %u NodeID = %u ",
                    SvPacket[i].GroupID,
                    SvPacket[i].NodeID);
            if (((OurProto != TDMA) && (OurProto != CSMA)) ||
                (OurProto == TDMA && ActiveNode[i] == 1)  ||
                (OurProto == CSMA && ActiveNode[i] == 1)){
                sprintf(Data,"Temp = %u%cC Light = %s RSSI = %u\r\n",
                    SvPacket[i].Temp,
                        degreesymbol,
                    lightstr[SvPacket[i].Light],
                    SvPacket[i].Strength); //Format ID, Data & RSSI as ASCII string for terminal
            } else {
                sprintf(Data,"Node Inactive\r\n");
            }
            strcat(Text,Data);
            USARTOut(Text,strlen(Text)); //output string to USART
        }
    }
    sprintf(Text,"\n");
    USARTOut(Text,strlen(Text));
    // Latest Data reported so consider node inactive until sends again
    ResetActiveNodes();
}

// Get Temperature Sensor Resistance Value
unsigned char getTemp() {
    unsigned int inttemp = 0;
    float floattemp = 0;
    unsigned char temp   = 0;
    signed char offsets[NUMNODES] = {79,80,74,79}; // offset for room temp
    float slope = -0.55;
    OpenADC(ADC_FOSC_16 & ADC_RIGHT_JUST & ADC_16_TAD,
            ADC_CH6 & ADC_INT_ON & ADC_VREFPLUS_VDD & ADC_VREFMINUS_VSS,
            7);
    Delay10TCYx(5);
    ConvertADC();
    while(BusyADC());
    inttemp = ReadADC();
    // ADC returns 10 bit number, to get most significant bits, we shift right
    // twice to drop the 2 least significate bits and take the lower half by casting
    temp = (char)(inttemp >> 2);
    // conversion - (y = mx+c) where m is 'slope' and c is 'offset'
    floattemp = (temp * slope) + offsets[ThisNode - 1];
    // convert to integer, with rounding
    temp = (int)floattemp;
    
    CloseADC();
    return temp;
}

// Get Light Sensor Resistance Value
unsigned char getLight() {
    unsigned int intlight = 0;
    unsigned char light   = 0;
    OpenADC(ADC_FOSC_16 & ADC_RIGHT_JUST & ADC_16_TAD,
            ADC_CH5 & ADC_INT_ON & ADC_VREFPLUS_VDD & ADC_VREFMINUS_VSS,
            7);
    Delay10TCYx(5);
    ConvertADC();
    while (BusyADC());
    intlight = ReadADC();
    // ADC returns 10 bit number, to get most significant bits, we shift right
    // twice to drop the 2 least significate bits and take the lower half by casting
    light = (char)(intlight >> 2);
    // conversion - light report kept simple, only three values reported
    if (light < 16) {
        light = Bright;
    } else if (light > 64) {
        light = Shadow;
    } else {
        light = Normal;
    }
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