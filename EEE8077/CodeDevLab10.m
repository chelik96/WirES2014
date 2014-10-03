function plot_16QAM_BER()
    initialise(); 
    % Make important constants global in scope
    global N M cp L Np Pv C P tau snr_dB snr_linear sv;
    N       = 2048; % Frame Size
    M       = 16;   % Constellation Size (16-QAM has 16 symbols)
    cp       = 128;  % Cyclic Prefix Length (could be 0, 16, 32, or 64)
    L       = 8;    % Frequency of pilots in the bit frame
    Np      = N/L;  % Number of pilots in a frame
    Pv      = 3+3j; % Pilot Value
    max_dB  = 40;   % Maximum Signal to Noise Ratio Level Generated
    step_dB = 2;    % Gap between SNR levels simulated from 0 to max_dB
    numsims = 500;   % Number of times to simulate each SNR value.
    BER_list= [];   % matrix to store the various BERs for each SNR value
    MSE_list= [];
    C=[ -3+3j, -3+1j, -3-3j, -3-1j, ... % 16-QAM Constellation matrix
        -1+3j, -1+1j, -1-3j, -1-1j, ...
         3+3j,  3+1j,  3-3j,  3-1j, ...
         1+3j,  1+1j,  1-3j,  1-1j ];
    P   = [0 -0.9 -4.9 -8.0 -7.8 -23.9]; % ITU Pedestrian Multipath mags
    tau = [0 5 18 27 52 84]; % Delay of multipath magnitudes
    snr_dB = [0:1:max_dB]; % Generate a range of SNR ratios
    snr_linear = 10.^(snr_dB/10); % convert Log dB scale to Linear scale
    sv = SigmaVector();
    zf = [];  % Initialise filter state (no interference yet)
    [H, h]  = multipath_init();
    
    disp('Starting Simulation');
    time=0;
    %matlabpool open % start default parallel computing system
    % we try SNR values from 0dB to 40dB stepping by 2dB each time
    for m = 0:1:max_dB/step_dB    % regular loop: swappable with parallel
    %parfor m = 0:1:max_dB/step_dB % parallel loop: swappable with regular
        snr = m * step_dB;
        errors = 0; % reset error counter for new SNR values
        mse_acc = 0; % reset mean square error accumulator
        b_est = zeros(1,N);
        tic;
        for n = numsims:-1:1
            [x, b] = Transmitter(); % Generate 16-QAM Signal 
            [z, zf]= Channel(x, sv(snr+1), h, zf); % Send thru noisy channel
            [b_est,D,mse]  = Receiver(z, H); % Retrieve info at other end
            b(1,1:L:end) = 0;  % ignore pilot positions - should be 9 in both b and b_est
            e_sym  = biterr(b, b_est); % Compare with original 
            errors = (e_sym/log2(M)) + errors; % nb. 4 bits per symbol...
            mse_acc = mse + mse_acc;
        end
        BER = (errors/numsims)/(N-Np);
        BER_list = [BER_list BER];
        MSE = mse_acc/numsims;
        MSE_list = [MSE_list MSE];
        disp(sprintf('\tSNR=%02.0fdB BER=%0.4f T=%0.1fs', snr, BER, toc));
        time = toc + time;
    end
    disp('Ending Simulation');
    %matlabpool close; % Close the parallel system down

    BERPlot(BER_list, time, H);
    MSEPlot(MSE_list);
end

function [RN, RS] = initialise()   
    clear; clc; close all; % Clear workspace
    RN = sum(100*clock);   % reset random number generator
    RS = RandStream('mt19937ar','seed',RN);
    RandStream.setGlobalStream(RS);
end

function sv = SigmaVector()
    global M C snr_linear;  % use globals from main function    
    mK = log2(M); % mK is bits per QAM symbol
    Es = 1/M * sum(abs(C).^2); % Energy per symbol
    Eb = Es/mK; % Eb is energy per bit
    En = Eb./snr_linear; % snr = Eb/En - rearranged
    sv = sqrt(En/2);
end

function [H, h] = multipath_init() 
    global N P tau; % use globals from main function
    h_i = sqrt(10.^(P/10));  % Channel magnitude
    U   = sqrt(sum(abs(h_i.^2))); % normalisation to unity i.e. sum(all)=1
    h_i = h_i/U; 
    h  = zeros(1,85); % initialize frequency response matrix (most zero)
    for i = 1:length(tau); % generate full frequency response
        h(tau(i)+1) = h_i(i); % add each given multipath delay magnitudes
    end
    H = fft(h, N);
end

function [x, b] = Transmitter()
    global N M cp L Pv C;       % use globals from main function
    D  = zeros(1, N);           % Initialize Frame (column matrix)
    b  = randi([0 (M-1)], 1, N);% Generate random symbols (0-15 for 16-QAM)
    D  = C(b+1);                % Use C as look-up to modulate frame

    D(1,1:L:end) = Pv;          % Insert Pilots

    d = sqrt(N)*ifft(D);        % Perform Inverse FFT and Normalize Energy
    x = [d(end-(cp-1) : end) d];% Insert Cyclic Prefix
end

function [z,zf] = Channel(x, stddev, h, zf)
    global N cp sv; % use globals from main function
    [y,zf] = filter (h, 1, x, zf); % Multipath noise added using fir filter
    w = stddev*(randn(1,N+cp) + (1j*randn(1,N+cp))); % create AWGN of frame size
    z = w+y; % add AWGN to the signal
end

function [b_est D mse] = Receiver(y, H)
    global N cp L Pv Np C; % use globals from main function
    d = y(cp+1:end);                    % Remove the Cyclic Prefix
    D = 1/sqrt(N)*fft(d);              % Perform FFT and Normalize Energy
    
    Hp = D(1,1:L:end)./Pv;             % Estimate unknown channel at pilots
    l = 1:L-1;
    for m = 1:Np-1                     % Interpolate all but the last bits
        n = (m-1)*L;                   % n is the OFDM index of the pilot
        k = n+l+1;                     % ks are the OFDM indexs of the values
    %   H_est(n+1) = Hp(m);            % Add pilots in (not for main sim)
        H_est(k) = Hp(m) + l/L.*(Hp(m+1)-Hp(m)); % add interpolated values
    end
    %H_est(((Np-1)*L)+1) = Hp(Np);     % Add final Pilot in (not for main sim)
    H_est(L*(Np-1)+2:N) = Hp(Np)+l/L.*(Hp(Np)-Hp(Np-1)); % extrapolate last values
    
    D = D./H_est;                      % 1 tap equalizer
    
    for i = 1:N                        % for each point in frame, find the
      [val, pos] = min(abs(C-D(:,i))); % symbol with min euclidean distance
      b_est(i) = pos - 1;              % and return index ie. demodulate
    end
    
    mse = mean(abs(H - H_est).^2);     % compute the mean-square error
end

function BERPlot(BER, time, H)
    global N snr_dB snr_linear;
    
    % Calculate Theoretical Response
    T_BER_16QAM_in_MP = 0;
    for i = 1:N
        T_BER_16QAM_in_MP  = T_BER_16QAM_in_MP + qfunc(sqrt(0.8*snr_linear*(abs(H(i)^2))));
    end
    T_BER_16QAM_in_MP = 1/N * T_BER_16QAM_in_MP;
    T_BER_16QAM_in_MP = (1-((1-(1.5*T_BER_16QAM_in_MP)).^2))/4;
    
    semilogy(snr_dB, T_BER_16QAM_in_MP,'r-');  % plotted for comparison
    hold on;
    semilogy(snr_dB(1:2:end), BER,'bo');        % Plot BER points
    ylim([1e-06 1]); xlim([1 40]);
    ylabel('P_e');   xlabel('$\gamma = \frac{E_b}{N_0}$ (dB)','interpreter','latex');
    legend('Theoretical', 'Simulated');grid on;
    title(sprintf(strcat('16-QAM in Multipath. Computed In: %0.1fsecs'), time));
end

function MSEPlot(MSE)
    global snr_dB;
    figure(2);
    semilogy(snr_dB(1:2:end), MSE);
    ylabel('e_{MSE}');   xlabel('$\gamma = \frac{E_b}{N_0}$ (dB)','interpreter','latex');
    title('Mean-squared error of 16-QAM Multipath Channel Estimation.');
end

function ConstellationPlot(frame)
    global C;
    plot(frame,'ro');
    hold
    plot(C,'ko','MarkerFaceColor','k','MarkerSize',10); % Black dots added (like figure on page 25 of handout
    axis([-4 4 -4 4]);
    ylabel('In-phase');
    xlabel('Quadrature');
end
