%% Demonstration Script
clear all;
clc;
fprintf('0. Ready To Start Demo\n');
pause;

%% 1. CHALLENGE GENERATION
% First Generate the challenge this is a list of 16-bit memory addresses,
% in this case 8, which amounts to just a random 128-bit number formatted
% as 32 digits of hexadecimal for the purposes of this demo.
% In practical usage care should be taken to weight the areas of memory
% queried to avoid areas of both highest and lowest metastability on the
% SRAM circuit and areas that degrade through age or temperature the worst.
C = challengegen();
% Display Current State
fprintf('1. Challenge Generated:\n');
cprintf('*blue','   %s\n',C);
pause;

%% 2. RAW PUF INTERACTION 1 (enrolment)
% Send the challenge to the FPGA over a serial communication and
% retrieve the PUF response (memory contents at addresses specified)
prompt = 'What is the PUF Output? ';
w = input(prompt,'s');
% Display Current State
fprintf('2. PUF Raw Response extracted:\n');
cprintf('*blue','   %s\n',w);
pause;

%% 3. FUZZY EXTRACTOR - GENERATION
% enrolment of the PUF - look into the code for it's design...
[R,s,x] = FuzzyGenerator(w);
% store the Response for later in the demo
original_response = R;
% Display Current State
fprintf('3. Fuzzy Extractor Generation Process:\n')
fprintf(' a) Original Response to verify against:\n');
cprintf('*blue','   %s\n',R);
fprintf(' b) Helper Data to include in challenge:\n s=');
cprintf('*blue','%s\n',s);
fprintf(' x=');
cprintf('*blue','%s\n',x);
pause;

%% 4. SEND EAP_PUF CHALLENGE
% send the Challenge bits, and the two piceces of helper data
p = GenerateRequest(C,s,x);
% Display Current State
fprintf('4. Ethernet EAP_PUF Request Packet created:\n');
% long string so split it in it's component parts before printing out
cprintf('*blue','   %s...\n',p(1:28));
cprintf('*blue','    %s... ',p(29:36));
cprintf('*blue','%s...\n',p(37:46));
cprintf('*blue','     %s...\n',p(47:78));
cprintf('*blue','     %s...\n',p(79:110));
cprintf('*blue','     %s...\n',p(111:142));
cprintf('*blue','   %s\n',p(143:end));
pause;

%% 5. RECEIVE EAP_PUF CHALLENGE
% extract the CHallenge and the helper data
[C,s,x] = ProcessRequest(p);
% Display Current State
fprintf('5. Ethernet EAP_PUF Request Packet received:\n C=');
cprintf('*blue','%s\n',C);
fprintf(' s=');
cprintf('*blue','%s\n',s);
fprintf(' x=');
cprintf('*blue','%s\n',x);
pause;

%% 6. RAW PUF INTERACTION 2 (verification)
prompt = 'What is the PUF Output? ';
w = input(prompt,'s');
% Display Current State
fprintf('6. PUF Raw Response extracted:\n');
cprintf('*blue','   %s\n',w);
pause;

%% 7. FUZZY EXTRACTOR - REPRODUCTION
% validation of the PUF - look into the code for it's design...
R = FuzzyReproducer(w,s,x);
% in practice an ethernet packet would be sent back... but skip this as
% we have already explored and it's the same technique
reproduced_response = R;
% Display Current State
fprintf('7. Fuzzy Extractor Reproduction Process:\n')
cprintf('*blue','   %s\n',R);
pause;

%% 8. VALIDATE
fprintf('8. ');
validator('demo', original_response, reproduced_response)