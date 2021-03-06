function plot_16QAM_BER()
    initialise(); 
    N       = 2048; % Frame Size
    M       = 16;   % Constellation Size (16-QAM has 16 symbols)
    k       = 0;   % Cyclic Prefix Length (could be 0, 16, 32, or 64)
    max_dB  = 20;   % Maximum Signal to Noise Ratio Level Generated
    step_dB = 1;    % Gap between SNR levels simulated from 0 to max_dB
    numsims = 500;   % Number of times to simulate each SNR value.
    BER_list= [];   % matrix to store the various BERs for each SNR value
    C=[ -3+3j, -3+1j, -3-3j, -3-1j, ... % 16-QAM Constellation matrix
        -1+3j, -1+1j, -1-3j, -1-1j, ...
         3+3j,  3+1j,  3-3j,  3-1j, ...
         1+3j,  1+1j,  1-3j,  1-1j ];
    snr_dB = [0:1:max_dB]; % Generate a range of SNR ratios
    snr_linear = 10.^(snr_dB/10); % convert Log dB scale to Linear scale
    sv = SigmaVector(snr_linear, M, C);
    
    disp('Starting Simulation');
    time=0;
    %matlabpool open % start default parallel computing system
    % we try SNR values from 0dB to 40dB stepping by 2dB each time
    for m = 0:1:max_dB/step_dB    % regular loop: swappable with parallel
    %parfor m = 0:1:max_dB/step_dB % parallel loop: swappable with regular
        snr = m * step_dB;
        errors = 0; % reset error counter for new SNR values
        b_est = zeros(1,N);
        tic;
        for n = numsims:-1:1
            [x, b] = Transmitter(N, M, C, k); % Generate 16-QAM Signal 
            y      = Channel(x, N+k, sv(snr+1)); % Send thru noisy channel
            b_est  = Receiver(y, N, k, C); % Retrieve info at other end
            e_sym = biterr(b, b_est, log2(M)); % Compare with original 
            errors = (e_sym/4) + errors;   % nb. 4 bits per symbol...
        end
        BER = (errors/numsims)/N;
        BER_list = [BER_list BER];
        disp(sprintf('\tSNR=%02.0fdB BER=%0.4f T=%0.1fs', snr, BER, toc));
        time = toc + time;
    end
    disp('Ending Simulation');
   % matlabpool close; % Close the parallel system down

    BERPlot(BER_list, snr_dB, time);
end

function [RN, RS] = initialise()   
    clear; clc; close all; % Clear workspace
    RN = sum(100*clock);   % reset random number generator
    RS = RandStream('mt19937ar','seed',RN);
    RandStream.setGlobalStream(RS);
end

function sv = SigmaVector(snr_linear, M, C)
    mK = log2(M); % mK is bits per QAM symbol
    Es = 1/M * sum(abs(C).^2); % Energy per symbol
    Eb = Es/mK; % Eb is energy per bit
    En = Eb./snr_linear; % snr = Eb/En - rearranged
    sv = sqrt(En/2);
end

function [x, b] = Transmitter(N, M, C, k)
    D  = zeros(1, N);           % Initialize Frame (column matrix)
    b  = randi([0 (M-1)], 1, N);% Generate random symbols (0-15 for 16-QAM)
    D  = C(b+1);                % Use C as look-up to modulate frame
    d = sqrt(N)*ifft(D);        % Perform Inverse FFT and Normalize Energy
    %x = [d(end-(k-1) : end) d]; % Insert Cyclic Prefix
    x=d;
end

function y = Channel(x, N, stddev)
    w = stddev*(randn(1,N)+1j*randn(1,N));  % add AWGN to the signal
    y=w+x;
end

function b_est = Receiver(y, N, k, C)
    %d = y(k+1:end);                    % Remove the Cyclic Prefix
    d = y;
    D = 1/sqrt(N)*fft(d);              % Perform FFT and Normalize Energy
    for i = 1:N                        % for each point in frame, find the
      [val, pos] = min(abs(C-D(:,i))); % symbol with min euclidean distance
      b_est(i) = pos - 1;              % and return index ie. demodulate
    end
end

function BERPlot(BER, dBRange, time)
    snr_linear = 10.^(dBRange/10); % Convert Log dB scale to Linear scale
    Q = qfunc(sqrt(0.8*snr_linear));
    T_BER_16QAM_in_AWGN = (1-((1-(1.5*Q)).^2))/4; % Theoretical Response
    semilogy(dBRange, T_BER_16QAM_in_AWGN,'r-');  % plotted for comparison
    hold on;
    semilogy(dBRange(1:1:end), BER,'b-');        % Plot BER line
    semilogy(dBRange(1:1:end), BER,'bo');        % Plot BER points
    ylim([1e-07 1]); xlim([0 16]);
    ylabel('P_e');   xlabel('\gamma = E_b / N_0 (dB)');
    legend('Theoretical', 'Simulated'); grid on;
    title(sprintf(strcat('16-QAM in AWGN. Computed In: %0.1fsecs'), time));
end


