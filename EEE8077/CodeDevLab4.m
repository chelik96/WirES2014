%--------------------------------------------------------------------------
% START OF INITIALIZATION

% Clear all variables from the workspace
clear;
clc;
close all;
% Reset Random Number Generator
RN = sum(100*clock);
RS = RandStream('mt19937ar','seed',RN);
RandStream.setGlobalStream(RS);

% END OF INITIALIZATION
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% START OF CONSTANTS DECLARATION

N      = 4092; % Frame Size
M      = 16;   % Constellation Size (Using 16-QAM, so 16 symbols required)
k      = 16;   % Cyclic Prefix Length (could be 0, 16, 32, or 64 samples)
m      = 16;   % Noise Level in dB for first plot
m_2    = 6;    % Noise Level in dB for second plot
max_dB = 40;   % Maximum Noise Level Generated

% 16-QAM Constellation matrix
C=[ -3+3j, -3+1j, -3-3j, -3-1j,...
    -1+3j, -1+1j, -1-3j, -1-1j,...
    3+3j, 3+1j, 3-3j, 3-1j,...
    1+3j, 1+1j, 1-3j, 1-1j ];

% END OF CONSTANTS DECLARATION
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------   
% START OF TRANSMITTER

% Generate a random symbol frame
D  = zeros(1, N);           % Initialize Frame (column matrix)
b = randi([0 (M-1)], 1, N); % Generate random symbols (0-15 for 16-QAM)
D  = C(b+1);                % Use C as look-up to Generate symbol frame
% Perform Inverse Fast Fourier Transform and Normalize Energy Levels
d = sqrt(N)*ifft(D);
% Insert Cyclic Prefix
x = [d(end-(k-1) : end) d]; % copy last 16 symbols to the front

% END OF TRANSMITTER
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% START OF COMMUNICATIONS CHANNEL

% Calculate AGWN sigma values
snr_db = [0:1:max_dB]; % Generate a range of SNR ratios
snr_linear = 10.^(snr_db/10); % convert Log dB scale to Linear scale
energy_symbol = 10; % see slide 46 for derivation
mK = log2(M); % mK is bits per QAM symbol
eb = energy_symbol/mK; % eb is energy per bit
noise_energy = eb./snr_linear; % work backwards and find noise given signal
sigma = sqrt(noise_energy/2); %

% add AWGN to the signal
w = sigma(m+1)*(randn(1,N+k)+1j*randn(1,N+k));
y=w+x;

% for Second plot - REMOVE IN LAB 5
w_2 = sigma(m_2+1)*(randn(1,N+k)+1j*randn(1,N+k));
y_2=w_2+x;

% END OF COMMUNICATIONS CHANNEL
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% START OF RECEIVER

% Remove the Cyclic Prefix
d = y(k+1:end);
% Perform Fast Fourier Transform
D_est = 1/sqrt(N)*fft(d);

% for Second plot - REMOVE IN LAB 5
d_2 = y_2(k+1:end);
D_est_2 = (1/sqrt(N))*fft(d_2);

% END OF RECEIVER
%--------------------------------------------------------------------------

% PLOT RESULTS

subplot(121),
plot(D_est,'ro');
ylabel('Quadrature');
xlabel('In-phase');
title('\gamma = \frac{\it{E_b}}{\it{N_0}} = 16dB')
grid on;
axis([-5 5 -5 5]);
hold;
plot(C,'ko','MarkerFaceColor','k','MarkerSize',10);


subplot(122),
plot(D_est_2,'ro');
ylabel('Quadrature');
xlabel('In-phase');
title('\gamma = \frac{\it{E_b}}{\it{N_0}} = 6 dB');
grid on;
axis([-5 5 -5 5]);
hold;
plot(C,'ko','MarkerFaceColor','k','MarkerSize',10);
