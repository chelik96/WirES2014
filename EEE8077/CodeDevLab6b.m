% Frequency Response of ITU Pedestrian B Ch. 103 Multipath Channel

clear all;
clc;

zf = []; % Initial Filter State
N = 2048;
P   = [0 -0.9 -4.9 -8.0 -7.8 -23.9]; % ITU Pedestrian Multipath mags
tau = [0 5 18 27 52 84]; % Delay of multipath magnitudes
h_i = sqrt(10.^(P/10));  % Channel magnitude
U   = sqrt(sum(abs(h_i.^2))); % normalisation to unity i.e. sum(all)=1
h_i = h_i/U; 
h  = zeros(1,85); % initialize frequency response matrix (mostly zero)
for i = 1:length(tau); % generate full frequency response
    h(tau(i)+1) = h_i(i); % add each given multipath delay magnitudes
end
H = fft(h, N);
plot(abs(H));
xlim([0 2048]);
title('Frequency Response of ITU Pedestrian B Ch. 103 Multipath Channel');
ylabel('$\left|H(k)\right|$','interpreter','latex');
xlabel('subcarrier index');

