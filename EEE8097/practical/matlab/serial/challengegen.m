function hexoutput = challengegen(n)
% CHALLENGEGEN generates a random PUF challenge of hex characters
% optional parameter 'n' sets the bit size of the challenge and therefore
% the equally sized PUF reponse. it defaults to 128 bits.
    switch nargin
        case 1
            nn = n;
        otherwise
            nn = 128;
    end    

    hexoutput = char(binaryVectorToHex(randi([0 1],1,nn)));
end

