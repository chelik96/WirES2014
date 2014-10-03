#include	<stdio.h>
#include	<stdlib.h>

typedef struct {
    unsigned char ID;
    unsigned int Temp;
    unsigned int Light;
    unsigned int CRC;
} PacketType;

unsigned int generate_crc(PacketType packet) {
	// we use the XMODEM poly (0x8408) to generate the CRC
	unsigned short crc_tbl[16] = {
		0x0000, 0x1E3D, 0x1C39, 0x0204, 0x1831, 0x060C, 0x0408, 0x1A35, 
		0x1021, 0x0E1C, 0x0C18, 0x1225, 0x0810, 0x162D, 0x1429, 0x0A14,
	};
	int i, ch;
	unsigned int acc = 0xFFFF;
	int *rawPacket = (int*)&packet;
	// Nibble-at-a-time processing.
	// Uses reflected algorithm, so lo-nibble processed first.
	for (i=0; i <= sizeof(&rawPacket); i++) {
		ch = rawPacket[i];
		acc = crc_tbl[(ch ^ acc) & 15] ^ (acc >> 4);
		acc = crc_tbl[((ch >> 4) ^ acc) & 15] ^ (acc >> 4);
	}
	return acc;
}

int	main(int argc, char **argv) {
	// Test packet-crc function
	PacketType testPacket = {23, 24, 13, 0};
	printf("%04X\n", generate_crc(testPacket));
	return 0;
}