%% EAP-PUF Demo (Without FPGA PUF)
%---------------------------------
% Michael Walker 2014

%% Initialization
clear all;
clc;

pufsize = 128;

% Challenge Generation - for now use the challenge only - not the raw puf
% response
w = challengegen(pufsize)

% generate some responses from an 'authentic' but degraded puf by adding a
% few random errors - default error correction should deal with 10 errors
% so try 0 5, 8, 9, 10, 11, 12 and 15 errors to test response
temp = xor(hexToBinaryVector(w,pufsize),randerr(1, pufsize,  5));
wa05 = char(binaryVectorToHex(temp))
temp = xor(hexToBinaryVector(w,pufsize),randerr(1, pufsize,  8));
wa08 = char(binaryVectorToHex(temp))
temp = xor(hexToBinaryVector(w,pufsize),randerr(1, pufsize,  9));
wa09 = char(binaryVectorToHex(temp))
temp = xor(hexToBinaryVector(w,pufsize),randerr(1, pufsize, 10));
wa10 = char(binaryVectorToHex(temp))
temp = xor(hexToBinaryVector(w,pufsize),randerr(1, pufsize, 11));
wa11 = char(binaryVectorToHex(temp))
temp = xor(hexToBinaryVector(w,pufsize),randerr(1, pufsize, 12));
wa12 = char(binaryVectorToHex(temp))
temp = xor(hexToBinaryVector(w,pufsize),randerr(1, pufsize, 15));
wa15 = char(binaryVectorToHex(temp))
% generate some responses from
wr1 = challengegen(pufsize)
wr2 = challengegen(pufsize)
wr3 = challengegen(pufsize)

%% Generation Procedure

[R,s,x] = FuzzyGenerator(w)

%% Reproduction Procedures On Authentic Device

R00 = FuzzyReproducer(w, s, x)
R05 = FuzzyReproducer(wa05, s, x)
R08 = FuzzyReproducer(wa08, s, x)
R09 = FuzzyReproducer(wa09, s, x)
R10 = FuzzyReproducer(wa10, s, x)
R11 = FuzzyReproducer(wa11, s, x)
R12 = FuzzyReproducer(wa12, s, x)
R15 = FuzzyReproducer(wa15, s, x)

%% Reproduction Procedure On Different Devices with random responses

RR1 = FuzzyReproducer(wr1, s, x)
RR2 = FuzzyReproducer(wr2, s, x)
RR3 = FuzzyReproducer(wr3, s, x)

%% Testing Response

validator('R00', R, R00);
validator('R05', R, R05);
validator('R08', R, R08);
validator('R09', R, R09);
validator('R10', R, R10);
validator('R11', R, R11);
validator('R12', R, R12);
validator('R15', R, R15);
validator('RR1', R, RR1);
validator('RR2', R, RR2);
validator('RR3', R, RR3);
