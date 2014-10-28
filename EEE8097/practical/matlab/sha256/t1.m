function output = t1(h,s1,ch,kt,wt)

  i = hex2dec(h);
  j = hex2dec(s1);
  k = hex2dec(ch);
  l = hex2dec(kt);
  m = hex2dec(wt);

  output = dec2hex(mod(i + j + k + l + m,2^32));
end
