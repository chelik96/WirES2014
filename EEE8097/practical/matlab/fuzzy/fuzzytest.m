%% Fuzzy Extractor Demo
%----------------------
% Michael Walker 2014

%% Initialization

% this is the test data - small change is OK, big change unacceptable
original_PUF_txt1 = 'thisisgooddata';
authntic_PUF_txt1 = 'thisasgooddata';
attacker_PUF_txt1 = 'veryevildatais';

% alternative data - attacker passes
original_PUF_txt2 = 'ismoregooddata';
authntic_PUF_txt2 = 'ismoreguoddata';
attacker_PUF_txt2 = 'ismoreevildata';

% Create binary data vector to use in the fuzzy extractor
% organize data as a binary value row vector and pad to 127 bits
original_PUF_data1 = [str2num(reshape(dec2bin(original_PUF_txt1)',[],1))' zeros(1,30)];
authntic_PUF_data1 = [str2num(reshape(dec2bin(authntic_PUF_txt1)',[],1))' zeros(1,30)];
attacker_PUF_data1 = [str2num(reshape(dec2bin(attacker_PUF_txt1)',[],1))' zeros(1,30)];

original_PUF_data2 = [str2num(reshape(dec2bin(original_PUF_txt2)',[],1))' zeros(1,30)];
authntic_PUF_data2 = [str2num(reshape(dec2bin(authntic_PUF_txt2)',[],1))' zeros(1,30)];
attacker_PUF_data2 = [str2num(reshape(dec2bin(attacker_PUF_txt2)',[],1))' zeros(1,30)];

% Create BCH Encoder and Decoders for the fuzzy extractor process
GenEnc = comm.BCHEncoder('CodewordLength',127,'MessageLength',64);
RepEnc = comm.BCHEncoder('CodewordLength',127,'MessageLength',64);
RepDec = comm.BCHDecoder('CodewordLength',127,'MessageLength',64);

%% Generation Procedure
w = original_PUF_data1;
% Produce a random 64 bit binary number for secure sketch encoder
k = randi([0 1],1,64);
% Produce a random 127 bit binary number for randomness extractor
x = randi([0 1],1,127);

% Sketch part of secure sketch
r = step(GenEnc, k')';
s = xor(r,w);

% Randomness Extraction (get hash output and rearrange to row vector)
xw = xor(x,w);
hash_result = hex2dec(sha256(binaryVectorToHex(xw)));
original_Response = str2num(reshape(dec2bin(hash_result,256)',[],1))';

%% Reproduction Procedure On Authentic Device

% Get PUF value (assume slight change in data)
w_dash = authntic_PUF_data1;

% Recovery part of secure sketch
r_dash = xor(s,w_dash);
k_repro = step(RepDec, r_dash')';
r_repro = step(RepEnc, k_repro')';
w_repro = xor(s, r_repro);

% Randomness Extraction (get hash output and rearrange to row vector)
xw_repro = xor(x,w_repro);
hash_result_r = hex2dec(sha256(binaryVectorToHex(xw_repro)));
reproduced_Response = str2num(reshape(dec2bin(hash_result_r,256)',[],1))';

%% Reproduction Procedure On Atacking Device

% Get PUF value (assume slight change in data)
w_dash_a = attacker_PUF_data2;

% Recovery part of secure sketch
r_dash_a = xor(s,w_dash_a);
k_repro_a = step(RepDec, r_dash_a')';
r_repro_a = step(RepEnc, k_repro_a')';
w_repro_a = xor(s, r_repro_a);

% Randomness Extraction (get hash output and rearrange to row vector)
xw_repro_a = xor(x,w_repro_a);
hash_result_a = hex2dec(sha256(binaryVectorToHex(xw_repro_a)));
reproduced_Response_a = str2num(reshape(dec2bin(hash_result_a,256)',[],1))';

%% Testing Response

AuthDist = pdist([+original_Response;+reproduced_Response],'hamming');
AttkDist = pdist([+original_Response;+reproduced_Response_a],'hamming');

if AuthDist == 0
    disp('Authentic Device Passed Verification');
else
    disp('Authentic Device Failed Verification');
end

if AttkDist == 0
    disp('Attackers Device Passed Verification');
else
    disp('Attackers Device Failed Verification');
end

