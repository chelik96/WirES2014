% pad the message to 512-bits
% original message should be a string of hexadecimal characters
% it can be no longer than 110 hexadecimal digits long
% output will be message of 128 hexadecimal digits (4 bits per hex * 128).

% it makes assumption that the hexadecimal digits are in pairs to represent
% bytes so there must be an even number of them for function to work..

% Adds stop bit (2 hex characters) and 64 bit length code (16 chars)
% Hence 110 is maximum orignal size..
function paddedmessage = padmessage(message)
    % work out the length of the message in binary digits
    l = size(message,2)*4;

    % add end bit - assume full bytes in, so just add a hex '80' (10000000)
    message = strcat(message, '80');

    % Create the zero padding, add 2 for the end bit we just added above
    k = 112-(l/4+2);

    % create a string of zeros k digits long
    zm = blanks(k);
    zm = strrep(zm,' ','0');

    % need to append the length as a 64-bit number (64/4 = 16 hex digits)
    append = dec2hex(l);
    % make it long enough
    za = blanks(16 - size(append,2));
    za = strrep(za,' ','0');
    append = strcat(za,append);

    paddedmessage = strcat(message, zm, append);
end
