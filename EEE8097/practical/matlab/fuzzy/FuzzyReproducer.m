%% Fuzzy Extractor Reproduction Procedure
% w - Raw PUF data as input, will be 1 bit longer than Code length (n),
%     by default this will be 127 - so w will be 128 bits. (requried)
% s - Helper Data 1 - Used in Secure Sketch Recovery (required)
% x - Helper Data 2 - Used in Randomness Extractor (required)
% k - Message Length used in BCH Encoder - defaults to 64 bits (optional
%     but should be the same as that used in the FUzzyGenerator function.
% R - Response of the fuzzy extractor - to compare with the
%     original response of the generation procedure to validate it.
%     (256-bits - SHA-256 output digest)
function R = FuzzyReproducer(w,s,x,k)
    % setup parameters to defaults if not passed in
    switch nargin
        case 4
            kk = k;  % veriable set message length
        otherwise
            kk = 64; % default message length = 64 bits
    end

    % convert hexadecimal inputs to binary vector format
    w = hexToBinaryVector(w,size(s,2)*4);
    s = hexToBinaryVector(s,size(s,2)*4);
    x = hexToBinaryVector(x,size(x,2)*4);
    
    % Trim s and x down to 2^m-1, instead of 2^m - remove MSB...
    s = s(2:end);
    x = x(2:end);
    
    % setup the BCH Encoder and Decoder used in Secure Sketch Recovery
    RepEnc=comm.BCHEncoder('CodewordLength',size(s,2),'MessageLength',kk);
    RepDec=comm.BCHDecoder('CodewordLength',size(s,2),'MessageLength',kk);

    % Recovery part of secure sketch
    % mod 2 add of secure sketch helper and puf data
    r = xor(s,w(2:end));
    k = step(RepDec, r')';
    r = step(RepEnc, k')';
    w = xor(s, r);

    % Randomness Extraction (get hash output and rearrange to row vector)
    xw = xor(x,w);
    R = sha256(char(binaryVectorToHex(xw)));
end

