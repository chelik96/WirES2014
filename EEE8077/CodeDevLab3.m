% Initialization
clear;
clc;
close all;

% Reset Random Number Generator
RN = sum(100*clock);
RS = RandStream('mt19937ar','seed',RN);
RandStream.setGlobalStream(RS);

% Constants Used In Script
N   = 2048; % Frame Size
M   = 16; % Constellation Size
k   = 16; % Cyclic Prefix Length - (could be 0, 16, 32, or 64 samples in project notes)

% 16-QAM Constellation matrix
C=[ -3+3j, -3+1j, -3-3j, -3-1j,...
    -1+3j, -1+1j, -1-3j, -1-1j,...
    3+3j, 3+1j, 3-3j, 3-1j,...
    1+3j, 1+1j, 1-3j, 1-1j ];

% Generate random symbol frame
D  = zeros(1, N);
bk = randi([0 (M-1)], 1, N);
D  = C(bk+1);


% Perform Fast Fourier Transform and
% Energy Normalization (scale asymmetric energy tranform to a symmetric one)
d = sqrt(N)*ifft(D);

% Insert Cyclic Prefix
x = [d(end-(k-1) : end) d];

% END OF TRANSMITTER
plot(x);

% plot results
subplot(221), plot(real(x));
title('Real Part');
subplot(222), plot(imag(x));
title('Imaginary Part');

subplot(223), plot(x,'ro');
title('scatter plot - probably gunk');