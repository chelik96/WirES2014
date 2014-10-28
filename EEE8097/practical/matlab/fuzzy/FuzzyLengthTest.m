%% EAP-PUF Width Tests
%---------------------
% Michael Walker 2014

%% Initialization
clear all;
clc;


% try different sizes
%--------------------
% generate integer for the code length for BCH encoder (allows 3..16)
m = 6;
% calc codelength
n = 2^m - 1;
% generate the possible combinations of message lenth for give codelength
minnums = bchnumerr(n);
% Select the middlle of the options for the actual message length
k = minnums(round(size(minnums,1)/2),2);
% keep note of the number of errors that will be corrected by the code
d = minnums(round(size(minnums,1)/2),3);
pufsize = n + 1;

% Challenge Generation - for now use the challenge only - not the raw puf
% response
w = challengegen(n + 1)

% generate some responses from an 'authentic' but degraded puf by adding a
% few random errors
temp = xor(hexToBinaryVector(w,pufsize),randerr(1, n+1,  4));
wa04 = char(binaryVectorToHex(temp))
temp = xor(hexToBinaryVector(w,pufsize),randerr(1, n+1,  5));
wa05 = char(binaryVectorToHex(temp))
temp = xor(hexToBinaryVector(w,pufsize),randerr(1, n+1,  6));
wa06 = char(binaryVectorToHex(temp))
temp = xor(hexToBinaryVector(w,pufsize),randerr(1, n+1,  7));
wa07 = char(binaryVectorToHex(temp))

% generate some responses from
wr1 = challengegen(n+1)
wr2 = challengegen(n+1)
wr3 = challengegen(n+1)

%% Generation Procedure

[R,s,x] = FuzzyGenerator(w, k, m)

%% Reproduction Procedures On Authentic Device

R00 = FuzzyReproducer(   w, s, x, k)
R04 = FuzzyReproducer(wa04, s, x, k)
R05 = FuzzyReproducer(wa05, s, x, k)
R06 = FuzzyReproducer(wa06, s, x, k)
R07 = FuzzyReproducer(wa07, s, x, k)

%% Reproduction Procedure On Different Devices with random responses

RR1 = FuzzyReproducer(wr1, s, x, k)
RR2 = FuzzyReproducer(wr2, s, x, k)
RR3 = FuzzyReproducer(wr3, s, x, k)

%% Testing Response

validator('R00', R, R00);
validator('R04', R, R04);
validator('R05', R, R05);
validator('R06', R, R06);
validator('R07', R, R07);
validator('RR1', R, RR1);
validator('RR2', R, RR2);
validator('RR3', R, RR3);