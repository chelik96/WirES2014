clc; clear all;
% read in the original fingerprint image
fingerprint = im2double(imread('Fingerprint.jpg'));

%% Equalization Step
% get the histogram of the original image
histogram = hist(fingerprint(:),256);
% calculate a mapping that will equalize the image
running_total = cumsum(histogram);
map = round(255*running_total/(size(fingerprint,1)*size(fingerprint,2)))+1;
% apply the mapping pixel-by-pixel to original image to get equalized image
 for x = 1:size(fingerprint,1)
    for y = 1:size(fingerprint,2)
        equal_fp(x,y) = map(round(fingerprint(x,y)*255)+1)/255;
    end
 end
 
%% Segmentation Step
% this is the block size - it is also used in other steps that use a
% block-by_block approach to processing the image for consistentcy
W = 16;
% if a block has less varience in it than the threshold it is discarded
variance_threshold = 0.015;
% empty matrix, ready to store the results of segmentation as a new image
segment_fp = ones(size(equal_fp));
% empty matrix, ready to store whether the block was kept in the new image
blocks = zeros(size(equal_fp)/W);
% Iterate block by block through the image
for x = 1:W:size(equal_fp,1)-W
    for y = 1:W:size(equal_fp,2)-W
        % initialize a count of the variance in this block
        variance = 0;
        % grab the current block and put it in it's own matrix 'block'
        block = equal_fp(x:x+W-1,y:y+W-1);
        % workout the variance on 16x16 block at origin(x,y)
        block_mean = sum(sum(block)')/(W^2);
        % sum up the variances
        for x2 = 1:size(block,1)
            for y2 = 1:size(block,2)
                variance = variance + (block(x2,y2) - block_mean)^2;
            end
        end
        % Normalize the Variance by averaging the sum 
        variance = variance / W^2;
        % Only Keep blocks with enough variance, else block left white (1s)
        if variance > variance_threshold
           segment_fp(x:x+W,y:y+W) = equal_fp(x:x+W,y:y+W);
           % mark this block as kept (1) rather than dropped (0)
           blocks(floor(x/W),floor(y/W)) = 1;
        end
    end
end
% keep a record of the current state of the segmentation for display later
segment_unfilled_fp = segment_fp;
% refill blocks that are inside the fingerprint
% uses the included imfill routine, not sure how to do it myself by 'hand'
% this matrix will be used later to keep track of blocks to ignore
mask = imfill(blocks,'holes');
% mark blocks that were dropped originally but are marked keep in the mask
refill_blocks = xor(mask,blocks);
% go through the image block-by block putting back 'undropped' blocks
for x = 1:size(blocks,1)
    for y = 1:size(blocks,2)
        if refill_blocks(x,y) == 1
            segment_fp(x*W:x*W+W,y*W:y*W+W) = equal_fp(x*W:x*W+W,y*W:y*W+W);
        end
    end
end

%% Normalization Step
% calculate current mean and variance and state desired values for these.
u  = mean(mean(segment_fp));
v  = var(segment_fp(:));
u0 = 0.5;
v0 = 0.23;
dv = v0/v;
% declare a new empty matrix to store the normalized image
normal_fp = zeros(size(segment_fp));
% iterate through the whole image pixel by pixel
for x = 1:size(segment_fp,1)
    for y = 1:size(segment_fp,2)
        % calculate root-squared difference from the mean for each pixel
        diff = sqrt((segment_fp(x,y)-u)^2 * dv);
        % shift the new pixel value away from the mean of the old image
        if segment_fp(x,y) > u
            normal_fp(x,y) = u0 + diff;
        else
            normal_fp(x,y) = u0 - diff;
        end
        % values cannot be less than 0 or greater than 1, so clip them
        if normal_fp(x,y) > 1
            normal_fp(x,y) = 1;
        end
        if normal_fp(x,y) < 0
            normal_fp(x,y) = 0;
        end
    end
end

%% Threshold Step (not really needed)
binary_fp = normal_fp > 0.5;

%% Sobel Step
% State the sobel filters as matrices
sobel_x = [-1 0 1; -2 0 2; -1 0 1];
sobel_y = [1 2 1; 0 0 0; -1 -2 -1];
% convolve the image with both sobel filters to get gradient
Gx = conv2(normal_fp,sobel_x,'same');
Gy = conv2(normal_fp,sobel_y,'same');

%% Local Ridge Orientation Step
% setup new matrix to store orientation angles
orient = zeros(floor(size(Gx)/W));
% go through the image block by block
for x = 1:W:size(Gx,1)-W
    for y = 1:W:size(Gx,2)-W
        % seperate out the current block from the larger image
        Gx_block = Gx(x:x+W-1,y:y+W-1);
        Gy_block = Gy(x:x+W-1,y:y+W-1);
        % compute the combined gradients
        Gxx = sum(sum((Gx_block^2)));
        Gyy = sum(sum((Gy_block^2)));
        Gxy = sum(sum((Gx_block.*Gy_block)));
        % determine orientation of each block
        orient(floor(x/W)+1,floor(y/W)+1) = (pi+atan2(2*Gxy,Gxx-Gyy))/2;
    end
end

%% Local Ridge Frequency Step
% setup new matrix to store orientation angles
orient = zeros(floor(size(Gx)/W));
% mask out the non-fingerprint areas
orient = and(orient,mask);
% need to look perpendicular to the ridges to find their frequency
perpend_orient = pi/2 + blocks;
% iterate image block-by-block and find ridge frequency
for x = 1:W:size(Gx,1)-W
    for y = 1:W:size(Gx,2)-W
        % grab the current block and put it in it's own matrix 'block'
        block = equal_fp(x:x+W-1,y:y+W-1);
        % grab the calculated across ridge angle for this block
        v = perpend_orient(floor(x/W)+1,floor(y/W)+1);
        vx = cos(v);
        vy = sin(v);
        %v_proj = block.*vx+block.*vy;
        %av = mean(v_proj);
        %peaks = minimas- where intensity changes flip (one way not either)
        %frequency = peaks/W; (w=1/s and s = w/no_of_peaks)
    end
end

%% Plot results - in reverse order, so easier to read through
figure('Name','Ridge Detection');
subplot(2,2,1);imshow(Gx);
subplot(2,2,2);imshow(Gy);

figure('Name','Segmentation & Normalization');
subplot(3,2,1);imshow(segment_unfilled_fp);
subplot(3,2,2);imshow(segment_fp);
subplot(3,2,3);imshow(normal_fp);
subplot(3,2,4);bar(hist(normal_fp(:),256));
xlim([0 256]); ylim([0,3200]);
subplot(3,2,5);imshow(1-(normal_fp));
subplot(3,2,6);imshow(binary_fp);

figure('Name','Equalization Step');
subplot(2,2,1);imshow(fingerprint);
subplot(2,2,2);bar(histogram);
xlim([0 256]);
subplot(2,2,3);imshow(equal_fp);
subplot(2,2,4);bar(hist(equal_fp(:),256));
xlim([0 256]);
