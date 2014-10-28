function output = Maj(a,b,c)
  x  = hex2dec(a);
  y  = hex2dec(b);
  z  = hex2dec(c);

  i = bitand(x,y);
  j = bitand(x,z);
  k = bitand(y,z);
  
  l = bitxor(i,j);
  m = bitxor(l,k);
  
  output = dec2hex(m);
end