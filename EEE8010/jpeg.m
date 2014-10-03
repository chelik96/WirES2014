%% JPEG implementation

% Load in picture as 2d matrix of 8bit intensity values
original_block = [
    48 53 58 62 64 64 64 64;
    53 60 62 65 58 65 65 65;
    59 64 69 72 67 65 65 65;
    68 70 71 69 69 68 68 68;
    68 69 70 71 71 64 64 64;
    70 70 70 70 69 66 66 66;
    71 71 70 72 71 66 66 66;
    71 71 70 70 72 67 67 67];

%% Encode

% shift positive to around zero values
displaced_block = original_block - 128;
% DCT
N = 8;
dct_block = zeros(N);
for u = 0:N-1
    for v = 0:N-1 
        for x = 0:N-1
            f_x = cos(pi*u*(2*x+1)/(2*N));
            for y = 0:N-1
                f_y = cos(pi*v*(2*y+1)/(2*N));
                dct_block(u+1,v+1) = dct_block(u+1,v+1) + displaced_block(x+1,y+1)*f_x*f_y;
            end
        end
        if (u==0) && (v==0)
                dct_block(u+1,v+1) = dct_block(u+1,v+1)/N;
        elseif (u==0) || (v==0)
            dct_block(u+1,v+1) = dct_block(u+1,v+1)*(sqrt(2)/N);
        else
            dct_block(u+1,v+1) = dct_block(u+1,v+1)*2/N;
        end
    end
end
% Quantize
quant_table = [
    16  11  10  16  24  40  51  61;
    12  12  14  19  26  58  60  55;
    14  13  16  24  40  57  69  56;
    14  17  22  29  51  87  80  62;
    18  22  37  56  68 109 103  77;
    24  35  55  64  81 104 113  92;
    49  64  78  87 103 121 120 101;
    72  92  95  98 112 100 103  99];
quantized_block = round(dct_block./quant_table);

% Zigzag - found solution on stackoverflow - seems to work well.
index = reshape(1:numel(quantized_block), size(quantized_block));
index = fliplr(spdiags( fliplr(index))); % get the anti-diagonals
index(:,1:2:end) = flipud( index(:,1:2:end) );  % reverse order odd columns
index(index==0) = []; % keep only the non-zero indices
zigzagged_block = quantized_block(index); % get elements in zigzag order

% DPCM on DC
% assume last block had a DC value of -34
last_block_dc = -34;
zigzagged_block(1,1) = last_block_dc - zigzagged_block(1,1);

% RLE/Huffman
runlengthencoded_block = [];
% Tables:
% 1: DC 
dc_vlc_table = [
    '00      ';
    '010     ';
    '011     ';
    '100     ';
    '101     ';
    '110     ';
    '1110    ';
    '11110   ';
    '111110  ';
    '1111110 ';
    '11111110'];
dc_vlc_table = cellstr(dc_vlc_table);

% First the DC
if zigzagged_block(1,1) == 0
    dc_vlc = dc_vlc_table(1);
    dc_vli = '';
else
    dc_vlc = dc_vlc_table(floor(log2(abs(zigzagged_block(1,1)))+1),1);
    if zigzagged_block(1,1) > 0
        dc_vli = dec2bin(zigzagged_block(1,1));
    else
        dc_vli = dec2bin(abs(zigzagged_block(1,1)));
        for i=1:size(dc_vli,2)
            if dc_vli(:,i)=='0'
                dc_vli(:,i)='1';
            else
                dc_vli(:,i)='0';
            end
        end
    end
end
output = strcat(dc_vlc,dc_vli)


% Show Result

%% Decode