gamma_dB     = 0:0.1:16;
gamma_linear = 10.^(gamma_dB/10);

ber_BPSK_in_AWGN  = qfunc(sqrt(2*gamma_linear));
ber_16QAM_in_AWGN = (1-((1-(1.5*qfunc(sqrt(0.8*gamma_linear)))).^2))/4;

semilogy(gamma_dB, ber_BPSK_in_AWGN,'r-');
hold on;
semilogy(gamma_dB, ber_16QAM_in_AWGN,'b--');
ylim([1e-06 1]);
xlim([1 16]);
title('Theoretical BER vs. $\frac{E_b}{N_0}$ performance for BPSK and 16-QAM through AWGN','interpreter','latex');
ylabel('$P_e$','interpreter','latex');
xlabel('$\gamma = \frac{E_b}{N_0} (dB)$','interpreter','latex');
legend('BPSK in AWGN', '16-QAM in AWGN');