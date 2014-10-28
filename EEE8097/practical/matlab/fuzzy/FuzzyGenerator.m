%% Fuzzy Extractor Generation Procedure
% w - Raw PUF data as input, will be 1 bit longer than Code length (n),
%     by default this will be 127 - so w will be 128 bits. (requried)
%     the first bit will not be used in the fuzzy extractor, as it requires
%     a length that is 2^m - 1, whereas the PUF data comes as multiples of
%     16-bit memory contents, and as such will not fit. exactly. Instead
%     the Fuzzy Extractor expects PUF data to equal 2^m (i.e. 1-bit larger)
% k - Messagte length (optional smaller will make fuzzy extractor more
%     robust - defaults to 64, which allows 10 errors to be corrected)
% m - Code length will be (2^m)-1, (optional - defaults to 7 - so n = 127)
% R - Original Response of the fuzzy extractor - to compare with the
%     later response of the reproduction procedure to validate it.
%     (256-bits - SHA-256 output digest)
% s - Helper Data 1 - Secure Sketch output of PUF & random 'rng1' data
%   - this will be 
% x - Helper Data 2 - Random 'rng2' value used in Randomness Extractor
function [R, s, x] = FuzzyGenerator(w,k,m)
    switch nargin
        case 3
            n = 2^m - 1; % variable set code length
        case 2
            n = 2^7 - 1; % default code length    = 127 bits
        otherwise
            k = 64;      % default message length = 64 bits
            n = 2^7 - 1; % default code length    = 127 bits
    end

    % convert hexadecimal input to binary vector format
    w = hexToBinaryVector(w,n+1);
    
    % setup the BCH Encoder used in the Secure Sketch
    GenEnc = comm.BCHEncoder('CodewordLength',n,'MessageLength',k);
    % Produce a random binary number of length 'k' for secure sketch, used
    % as the message for the bch encoder to encode and in some sense this
    % is what is ultimately the job of the FuzzyReproducer to recreate.
    rng1 = randi([0 1],1,k); 
    % Produce a random  binary number of length 'n', it will be combined
    % with the (almost all) of the PUF data for use in randomness extractor
    rng2 = randi([0 1],1,n);

    % Perfore the Sketch part of secure sketch by running the BCH encoder
    % on the rng1 data and xoring the result with (almost all) the PUF data
    % then output the result as Hexadecimal helper data 's'.
    ss = step(GenEnc, rng1')';
    sbin = xor(ss,w(2:end));
    s = char(binaryVectorToHex(sbin));

    % Peform the Randomness Extraction by running the SHA-256 hash function
    % on the xor of (almost all) the puf data and a complementary random
    % number to get the digest output (rearranged to row vector)
    xw = xor(rng2,w(2:end));
    R = sha256(char(binaryVectorToHex(xw)));
    % output the random number used in the rondomness extractor
    % to be used as helper data 'x'
    x = char(binaryVectorToHex(rng2));
end