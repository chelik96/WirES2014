%% GenerateRequest
% This takes the data required to issue a PUF challenge in hexadecimal and
% generates an ethernet packet containing EAPoL EAP_PUF request packet
%
% C      - The Challenge (will be 16 bytes long in demo) (input)
% x      - Helper Data 1 (will be 16 Bytes long in demo) (input)
% s      - Helper Data 2 (will be 16 Bytes long in demo) (input)
% packet - full ethernet packet represented in Hexadecimal (output)
function packet = GenerateRequest(C,s,x)
    % ensure challenge data are strings (not cell arrays) for processing
    C = char(C);
    x = char(x);
    s = char(s);
    
    % Start with the Ethernet packet header
    destinationMAC = '00005E005301'; % reserved MAC addr for documentation
    sourceMAC      = '00005E0053FF'; % reserved MAC addr for documentation
    etherType      = '888E';         % type for IEEE802.1x (EAPoL packets)
    packet = strcat(destinationMAC, sourceMAC, etherType);
    % Append EAPoL Header
    eapolVersion   = '02';  % always version 2
    eapolCode      = '00';  % EAP authentication data is always 0
    % nb. for length EAP_PUF Packet body should be 75 bytes long: 
    %       5 Byte EAP Header
    %    + 16 Byte Challenge
    %    + 32 Bytes of Helper Data
    %   =  53 Bytes - (which is 35 in Hex)
    length         = '0035';    % for demo this can be set
    packet = strcat(packet, eapolVersion, eapolCode, length);
    % Append EAP header
    eapCode        = '01';  % This is a EAP request packet; code = '1' 
    eapIdentity    = '55';  % Assumed for demo purposes
    eapType        = 'B0';  % EAP_PUF type (decimal 192)
    packet = strcat(packet, eapCode, eapIdentity, length, eapType);
    % Append challenge and helpder data
    packet = strcat(packet, C, x, s);
    % Finally Append the CRC and ensure output is string not cellarray.
    packet = strcat(packet, crc(packet));
    packet = char(packet);
end
