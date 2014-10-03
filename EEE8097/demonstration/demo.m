%% Demonstration Script

%% 1. CHALLENGE GENERATION
% First Generate the challenge this is a list of 16-bit memory addresses,
% in this case 8, which amounts to just a random 128-bit number formatted
% as 32 digits of hexadecimal for the purposes of this demo.
% In practical usage care should be taken to weight the areas of memory
% queried to avoid areas of both highest and lowest metastability on the
% SRAM circuit and areas that degrade through age or temperature the worst.
challengegen()

%% 2. RAW PUF INTERACTION 
% Send the challenge to the FPGA over a serial communication and
% retrieve the PUF response (memory contents at addresses specified)
w = input('PUF>')

[R,x,s] = FuzzyGenerator(w)
