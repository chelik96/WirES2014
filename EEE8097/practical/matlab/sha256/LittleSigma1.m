function output = LittleSigma1(w)
  x  = hex2dec(w);
  
  rotr17  = bitror(ufi(x,32,0),17);
  rotr19  = bitror(ufi(x,32,0),19);
  srl10   = bitsrl(ufi(x,32,0),10);
  
  i = bitxor(rotr17,rotr19);
  j = bitxor(i,srl10);
  output = j.hex;
end