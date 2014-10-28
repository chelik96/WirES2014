%% Validator
% Checks that two responses (SHA-256 digests in hex) are identical.
% - R_orig  : Response from the FuzzyGenerator
% - R_repro : Response from the FuzzyReproducer
% - name    : Device name under test (i.e. where the response of the 
%             FuzzyReproducer comes from)
function validator(name, R_orig, R_repro)
    RH1 = hexToBinaryVector(R_orig,size(R_orig,2)*4);
    RH2 = hexToBinaryVector(R_repro,size(R_orig,2)*4);
    
	Dist = pdist([+RH1; +RH2],'hamming');

    if Dist == 0
        message = sprintf('The %s device passed verification',name);
        disp(message);
    else
        message = sprintf('The %s device failed verification, distance: %.1f%%',name,Dist*100);
        disp(message);
    end
end