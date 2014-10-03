% Initialization
clear;
clc;
close all;

% Reset Random Number Generator
RN=sum(100*clock);
RS=RandStream('mt19937ar','seed',RN);
RandStream.setGlobalStream(RS);

% Constants Used In Script
FRAME_SIZE = 2048;
ALPHABET   = 16;
NOISE_DEV  = 0.25;

% 16-QAM Constellation matrix
C=[ -3+3j, -3+1j, -3-3j, -3-1j,...
    -1+3j, -1+1j, -1-3j, -1-1j,...
    3+3j, 3+1j, 3-3j, 3-1j,...
    1+3j, 1+1j, 1-3j, 1-1j ];

% Generate random symbol frame
D=zeros(1,FRAME_SIZE);
bk=randi([0 15],1,FRAME_SIZE);
for n=1:FRAME_SIZE
    D(n) = C(bk(n)+1);
end

% Generate Frame
frame = randsrc(1,FRAME_SIZE,D);

% Add AWGN to frame
noise = NOISE_DEV*[complex(randn(1,FRAME_SIZE),randn(1,FRAME_SIZE))];
noisyframe = frame+noise;

% Plot Frame
plot(noisyframe,'ro');
hold
plot(frame,'ko','MarkerFaceColor','k','MarkerSize',10); % Black dots added (like figure on page 25 of handout
axis([-4 4 -4 4]);
ylabel('In-phase');
xlabel('Quadrature');