function output = Ch(e,f,g)
  x  = hex2dec(e);
  nx = bitxor(x,hex2dec('ffffffff'));
  y  = hex2dec(f);
  z  = hex2dec(g);

  i = bitand(x,y);
  j = bitand(nx,z);
  
  k = bitxor(i,j);
  
  output = dec2hex(k);
end