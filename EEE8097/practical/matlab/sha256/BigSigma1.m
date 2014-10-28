function output = BigSigma1(e)
  x  = hex2dec(e);
  
  rotr6  = bitror(ufi(x,32,0), 6);
  rotr11 = bitror(ufi(x,32,0),11);
  rotr25 = bitror(ufi(x,32,0),25);
  
  i = bitxor(rotr6,rotr11);
  j = bitxor(i,rotr25);
  output = j.hex;
end