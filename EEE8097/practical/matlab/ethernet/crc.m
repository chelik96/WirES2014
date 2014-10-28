%% shift register 'like' implementation of CRC-32 encoder for ethernet FCS
function output = crc(packet)
    % generator polynomial for CRC-32
    poly = [1 0 0 0 0 0 1 0 0 1 1 0 0 0 0 0 1 0 0 0 1 1 1 0 1 1 0 1 1 0 1 1 1]';
    % you can use binaryVectorToHex to get 0x104c11db7) to check correct

    % convert the hex input into a binary vector
    % also, it needs to be > 32 bits for this to work, so if input is
    % 8 hex digits (32 bits) or less then pad with leading zeros
    if (size(char(packet),2) < 9)
        bits = hexToBinaryVector(packet,36)';
    else
        bits = hexToBinaryVector(packet)';
    end
    % Flip the first 32 bits (this is required by the spec...
    bits(1:32) = 1 - bits(1:32);
    % Add 32 zeros at the back for easier processing
    bits = [bits; zeros(32,1)];
    % Initialize the remainder calculator to all zeros
    rem = zeros(32,1);
    
    % Main compution loop
    for i = 1:length(bits)
        % like a lfsr we keep appending bits to the end
        rem = [rem; bits(i)];
        % modulo 2 addition, only need to add when '1' in remainder bit
        if rem(1) == 1
            rem = mod(rem + poly, 2);
        end
        % shift the register along before adding next bit
        rem = rem(2:33);
    end

    % output the compliment of the remainder as the CRC
    output = char(binaryVectorToHex((1 - rem)'));    
end