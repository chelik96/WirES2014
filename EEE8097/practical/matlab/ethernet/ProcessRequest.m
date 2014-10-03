%% ProcessRequest
% This takes a hexadecimal ethernet packet and extracts the required
% PUF challenge data from it, to be used to generate reponse
%
% packet - full ethernet packet represented in Hexadecimal
% C      - The Challenge (will be 16 bytes long)
% x      - Helper Data 1 (will be 16 Bytes long)
% s      - Helper Data 2 (will be 16 Bytes long)
function [ C,s,x ] = ProcessRequest( packet )
    % ensure packet is a string (not cell array) for processing
    packet = char(packet);  
    % Packet should be 75 bytes long: 
    %      14 Byte Ethernet Header
    %    +  4 Byte EAPoL Header
    %    +  5 Byte EAP Header
    %    + 16 Byte Challenge
    %    + 32 Bytes of Helper Data
    %    +  4 Byte CRC32 FCS (Frame Check Sequence)
    %   =  75 Bytes
    % required challenge should start at the 24th byte and be 16 bytes long
    % however this number needs to be doubled to '32' as the hex digits
    % represent nibbles of 4-bits, not Bytes of 8-bits. so 32 hex digits
    % for 128 bits of data.
    C = packet(47:78);
    % Helper data comes straight after and are both 16 bytes long too
    x = packet(79:110);
    s = packet(111:142);
end

