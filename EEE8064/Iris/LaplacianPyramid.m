%% Laplacian Pyramid Implementation

% Get eye picture
eye = im2double(imread('iris.jpg'));

% Crop to a square with side length a multiple of 16 and normalize for g0
g0 = eye(180:180+(28*16)-1,480:480+(28*16)-1);

% Prepare convolution matrix
w = [1 4 6 4 1]/16; 
W = w'*w;

% Create 3 more repeatedly smoothed and halved versions of the original
g1 = conv2(g0,W,'same'); g1 = g1(1:2:end,1:2:end);
g2 = conv2(g1,W,'same'); g2 = g2(1:2:end,1:2:end);
g3 = conv2(g2,W,'same'); g3 = g3(1:2:end,1:2:end);

% Create the difference images (compression error/loss)
i0 = zeros(size(g0)); i0(2:2:end,2:2:end) = g1;
i0 = g0-conv2(i0,4*W,'same')+0.5;
i1 = zeros(size(g1)); i1(2:2:end,2:2:end) = g2;
i1 = g1-conv2(i1,4*W,'same')+0.5;
i2 = zeros(size(g2)); i2(2:2:end,2:2:end) = g3;
i2 = g2-conv2(i2,4*W,'same')+0.5;

% Put the seperate images together in one image for better comparison
s0 = size(g0,1); s1 = size(g1,1); s2 = size(g2,1); s3 = size(g3,1);
g_py = zeros([s0,s0+s1+s2+s3]);
g_py(1:s0,1:s0) = g0;
g_py(1:s1,s0+1:s0+s1) = g1;
g_py(1:s2,s0+s1+1:s0+s1+s2) = g2;
g_py(1:s3,s0+s1+s2+1:s0+s1+s2+s3) = g3;

i_py = zeros([s0,s0+s1+s2]);
i_py(1:s0,1:s0) = i0;
i_py(1:s1,s0+1:s0+s1) = i1;
i_py(1:s2,s0+s1+1:s0+s1+s2) = i2;

% Display images
figure('Name','Laplacian Image Pyramid','NumberTitle','off'); imshow(g_py);
figure('Name','Pyramid of Differences','NumberTitle','off'); imshow(i_py);