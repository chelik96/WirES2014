function output = LittleSigma0(w)
  x  = hex2dec(w);
  z  = fi(x,0,32,0);
  
  rotr7  = bitror(z, 7);
  rotr18 = bitror(z,18);
  srl3   = bitsrl(z, 3);
  
  i = bitxor(rotr7,rotr18);
  j = bitxor(i,srl3);
  output = j.hex;
end