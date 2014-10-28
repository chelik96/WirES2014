function output = hexadd(x,y)
  x = char(x);
  y = char(y);
  result = dec2hex(mod(hex2dec(x) + hex2dec(y),2^32));
  % keep the output the same size as the input
  input_size = max([size(x,2);size(y,2)]);
  diff_size = input_size - size(result,2);
  if diff_size == 0
      output = result;
  elseif diff_size > 0
      % create a string of zeros diff_size digits long
      pad = blanks(diff_size);
      pad = strrep(pad,' ','0');
      output = strcat(pad,result);
  else
      % remove the MSB 4 bits (like a crude overflow)
      output = result(abs(diff_size)+1:end);
  end
end