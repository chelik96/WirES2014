function output = t2(s0,maj)

  i = hex2dec(s0);
  j = hex2dec(maj);
  
  output = dec2hex(mod(i + j,2^32));
end
