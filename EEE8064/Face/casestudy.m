%% PCA Case Study Implmentation

%% Step 1: Create Dataset
face1 = [0 0 0 1 0 1 0 0 0 1 0 0 1 0 1 1 0 0 0 1 0 0 0 1 0]';
face2 = [0 0 0 0 1 1 0 0 0 1 0 0 1 0 1 1 0 0 0 1 0 0 0 0 1]';
face3 = [0 0 0 1 0 1 0 0 0 1 0 1 1 0 1 1 0 0 0 1 0 0 0 1 0]';
face4 = [0 0 0 0 1 1 0 0 0 1 0 1 1 0 1 1 0 0 0 1 0 0 0 0 1]';
face5 = [1 0 0 1 0 1 0 0 0 1 0 1 1 0 1 1 0 0 0 1 1 0 0 1 0]';
unknown1 = [0 0 0 0 0.4 1 0.8 0 0 0.6 0 1 1 0 1 1 0 0 0.2 1 0.4 0 0 0 1]';
unknown2 = [0 0 0 1 0 1 0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0]';
unknown3 = [1 0.5 0.5 0.5 0.5 1 0.5 0.5 0.5 0.5 0 0.5 0.5 0.5 0.5 1 0.5 0.5 0.5 0.5 1 0.5 0.5 0.5 0.5]';
X = [face1 face2 face3 face4 face5];
[m n] = size(X);

%% Step 2: Subtracting 'Average face'
E = mean(X,2);
A = X-repmat(E,1,n);

%% Step 3: Covariance Matrix
C = A*A'/n;

%% Step 4: Eigenvalues & Eigenvectors
[u, lambda] = eig(C);
% show 'eigenfaces'
imshow(reshape(1-abs(u(:,end)),n,n)); figure;
imshow(reshape(1-abs(u(:,end-1)),n,n)); figure;
imshow(reshape(1-abs(u(:,end-2)),n,n)); figure;

%% Step 5: Reducing Dimensionality
% only take the 'd' most significant eigenvalues
d = 2;
lambda = fliplr(diag(lambda(end-(d-1):end,end-(d-1):end)));
u = fliplr(u(:,end-(d-1):end));

%% Step 6: Feature Vectors Reconstruction
Y = u'*A;
% plot the resulting feature vectors (only works if d=2)
dx=0.1;
scatter(Y(1,:),Y(end,:));
text(Y(1,:)+dx, Y(end,:)+dx, cellstr(num2str([1:5]')));
hold on;

%% Step 7: Finally, Recognition
Y1 = u'*(unknown1-E);
Y2 = u'*(unknown2-E);
Y3 = u'*(unknown3-E);
scatter(Y1(1),Y1(2),'Marker','p','SizeData',20^2);
text(Y1(1)+dx, Y1(2)+dx, 'Unknown1');
scatter(Y2(1),Y2(2),'Marker','p','SizeData',20^2);
text(Y2(1)+dx, Y2(2)+dx, 'Unknown2');
scatter(Y3(1),Y3(2),'Marker','p','SizeData',20^2);
text(Y3(1)+dx, Y3(2)+dx, 'Unknown3');