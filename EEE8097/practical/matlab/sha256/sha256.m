% SHA-256 Implementation
% Only capable of one 512-bit block
% for purposes of integration into fuzzy extractor project

% very inefficient - works on string representations of hexadecimal numbers
% this is for the purposes of clarity of design, as speed is not an issue

function digest = sha256(message)
  % setup initial hash values
  % nb. obtained from the fractional parts of the square roots of the first
  % eight prime numbers
  H = {...
	'6a09e667', 'bb67ae85', '3c6ef372', 'a54ff53a',...
    '510e527f', '9b05688c', '1f83d9ab', '5be0cd19'};

  % the 64 constants used for K values..
  K = {...
	'428a2f98', '71374491', 'b5c0fbcf', 'e9b5dba5', '3956c25b',...
    '59f111f1', '923f82a4', 'ab1c5ed5', 'd807aa98', '12835b01',...
    '243185be', '550c7dc3', '72be5d74', '80deb1fe', '9bdc06a7',...
    'c19bf174', 'e49b69c1', 'efbe4786', '0fc19dc6', '240ca1cc',...
    '2de92c6f', '4a7484aa', '5cb0a9dc', '76f988da', '983e5152',...
    'a831c66d', 'b00327c8', 'bf597fc7', 'c6e00bf3', 'd5a79147',...
    '06ca6351', '14292967', '27b70a85', '2e1b2138', '4d2c6dfc',...
    '53380d13', '650a7354', '766a0abb', '81c2c92e', '92722c85',...
    'a2bfe8a1', 'a81a664b', 'c24b8b70', 'c76c51a3', 'd192e819',...
    'd6990624', 'f40e3585', '106aa070', '19a4c116', '1e376c08',...
    '2748774c', '34b0bcb5', '391c0cb3', '4ed8aa4a', '5b9cca4f',...
    '682e6ff3', '748f82ee', '78a5636f', '84c87814', '8cc70208',...
    '90befffa', 'a4506ceb', 'bef9a3f7', 'c67178f2'};

  % initialise registers - to initial hash values
  a = H(1);
  b = H(2);
  c = H(3);
  d = H(4);
  e = H(5);
  f = H(6);
  g = H(7);
  h = H(8);

  % initialise the 16 message schedule registers
  W = {...
    '0000000', '0000000', '0000000', '0000000',...
    '0000000', '0000000', '0000000', '0000000',...
    '0000000', '0000000', '0000000', '0000000',...
    '0000000', '0000000', '0000000', '0000000'};

  % pad message to 512-bits
  paddedmessage = padmessage(message);

  % apply the compression function and update the registers
  for j = 1:64

    % compute message schedule
    if j <= 16
       % for first 16 iterations we just copy the message to the registers
       % so move next 32bit chunk of message into the message scheduler
       messagechunk = paddedmessage((j-1)*8+1:j*8);
       W(17-j) = cellstr(messagechunk);
       Wout = W(17-j);
    else
       % now message is in we can perform the scrambling functions

       %get the next scrambled input to the message block
       temp1 = hexadd(W(16), LittleSigma0(W(15)));
       temp2 = hexadd(temp1, W(7));
       temp3 = hexadd(temp2, LittleSigma1(W(2)));

       % shift registers once writting in the new value to the vacant pos.
       W(2:16) = W(1:15);
       W(1)  = cellstr(temp3);
       Wout = W(1);
    end

    % Compute compression function subfunctions

    tt1 = t1(h, BigSigma1(e), Ch(e, f, g), K(j), Wout);
    tt2 = t2(BigSigma0(a), Maj(a, b, c));

    % perform compression function on registers
    h = g;
    g = f;
    f = e;
    e = cellstr(hexadd(d,tt1));
    d = c;
    c = b;
    b = a;
    a = cellstr(hexadd(tt1,tt2));
  end

  % compute the final hash value (only one block, so end here)

  H(1) = cellstr(hexadd(a, H(1)));
  H(2) = cellstr(hexadd(b, H(2)));
  H(3) = cellstr(hexadd(c, H(3)));
  H(4) = cellstr(hexadd(d, H(4)));
  H(5) = cellstr(hexadd(e, H(5)));
  H(6) = cellstr(hexadd(f, H(6)));
  H(7) = cellstr(hexadd(g, H(7)));
  H(8) = cellstr(hexadd(h, H(8)));


  digest = char(strcat(H(1),H(2),H(3),H(4),H(5),H(6),H(7),H(8)));
end
