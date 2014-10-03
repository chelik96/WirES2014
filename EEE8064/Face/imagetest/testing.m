
%% Create the Training Database
ImageDir = 'H:\Projects\EEE8064\imagetest\';
ImageFiles = dir(strcat(ImageDir, '*.png'));
T = [];
for i = 1:size(ImageFiles,1)
   img = imread(strcat(ImageDir, ImageFiles(i).name));
   img = reshape(img,prod(size(img)),1);
   T = [T img];
end

%% Use PCA to generate 'EigenFaces'
m = mean(T,2);
A = [];
for i = 1:size(T,2)
    temp = double(T(:,i)) - m;
    A = [A temp];
end
L = A'*A;
[V D] = eig(L);
E = [];
for i = 1:size(V,2);
    if(D(i,i)>1)
        E = [E V(:,i)];
    end
end
E = A * E;

%% Test an image against the database to find a match
i  = inputdlg('Enter test image number (1-5)','EigenFaces System',1);
i = str2num(cell2mat(i));
img = imread(strcat(ImageDir, ImageFiles(i).name));
