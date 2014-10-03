clear all;
clc;

N = 2048;
gamma_dB     = 0:0.1:40;
gamma_linear = 10.^(gamma_dB/10);
P   = [0 -0.9 -4.9 -8.0 -7.8 -23.9]; % ITU Pedestrian Multipath mags
tau = [0 5 18 27 52 84]; % Delay of multipath magnitudes
zf = []; % Initial Filter State    
h_i = sqrt(10.^(P/10));  % Channel magnitude
U   = sqrt(sum(abs(h_i.^2))); % normalisation to unity i.e. sum(all)=1
h_i = h_i/U; 
h  = zeros(1,85); % initialize frequency response matrix (most zero)
for i = 1:length(tau); % generate full frequency response
    h(tau(i)+1) = h_i(i); % add each given multipath delay magnitudes
end
H = fft(h, N);
ber_BPSK_in_Multipath = 0;
for i = 1:N
    ber_BPSK_in_Multipath  = ber_BPSK_in_Multipath + qfunc(sqrt(2*gamma_linear*(abs(H(i)^2))));
end
ber_BPSK_in_Multipath = 1/N * ber_BPSK_in_Multipath;

ber_16QAM_in_Multipath = 0;
for i = 1:N
    ber_16QAM_in_Multipath  = ber_16QAM_in_Multipath + qfunc(sqrt(0.8*gamma_linear*(abs(H(i)^2))));
end
ber_16QAM_in_Multipath = 1/N * ber_16QAM_in_Multipath;
ber_16QAM_in_Multipath = (1-((1-(1.5*ber_16QAM_in_Multipath)).^2))/4;

semilogy(gamma_dB, ber_BPSK_in_Multipath,'r-');
hold on;
semilogy(gamma_dB, ber_16QAM_in_Multipath,'b--');
title('Theoretical BER vs. $\frac{E_b}{N_0}$ performance for BPSK and 16-QAM through ITU multipath channel','interpreter','latex');
ylim([1e-12 1]);
xlim([1 40]);
ylabel('$P_e$','interpreter','latex');
xlabel('$\gamma = \frac{E_b}{N_0} (dB)$','interpreter','latex');
legend('BPSK in Multipath', '16-QAM in Multipath');