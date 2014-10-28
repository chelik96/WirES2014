function output = BigSigma0(a)
  x  = hex2dec(a);
  
  rotr2  = bitror(ufi(x,32,0), 2);
  rotr13 = bitror(ufi(x,32,0),13);
  rotr22 = bitror(ufi(x,32,0),22);
  
  i = bitxor(rotr2,rotr13);
  j = bitxor(i,rotr22);
  output = j.hex;
end