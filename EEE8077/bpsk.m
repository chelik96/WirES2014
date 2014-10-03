function [d, C] = bpsk(N,M)
% BPSK - Generates Binary Phase Shift Keying (BPSK) Symbols
% Usage: [d, constel] = bpsk(M, N)
%	M,N:	Dimension of the output BPSK matrix d
%	d:	Output BPSK matrix
%	C:	BPSK constellation
  d=sign(randn(N,M));
  C=[-1 1];
endfunction
