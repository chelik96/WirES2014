-To _ generate the full 16-bit CRC table using the "reflected" algorithm in cygwin: 

 gcc crcmodel.c crctable.c -o crctable

-To run the program:
 ./crctable

 (The table is stored in crctable.h)


-An example of how to use the table in byte-by-byte and nibble-by-nibble form check the
crctest.c file. To compile the example in cygwin:

 gcc crcmodel.c crctest.c -o crctest

-To run the program:
 ./crctest Readme.txt

 (This computes the crc of the file Readme.txt)

You can modify the code in crctest.c very easily for needs of the crc computation required in 
the sensor network project. 
