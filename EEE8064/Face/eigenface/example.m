clear all
clc
close all

% Set Directories where images reside
TrainDatabasePath = uigetdir('Z:\Development\EEE8064\PCA_based Face Recognition System', 'Select training database path' );
TestDatabasePath = uigetdir('Z:\Development\EEE8064\PCA_based Face Recognition System', 'Select test database path');

% Set a test image to try and recognize
prompt = {'Enter test image name (a number between 1 to 10):'};
dlg_title = 'Input of PCA-Based Face Recognition System';
num_lines= 1;
def = {'1'};
TestImage  = inputdlg(prompt,dlg_title,num_lines,def);
TestImage = strcat(TestDatabasePath,'\',char(TestImage),'.png');
im = imread(TestImage);

% Main Functionality
T = CreateDatabase(TrainDatabasePath);
[m, A, Eigenfaces] = EigenfaceCore(T);
OutputName = Recognition(TestImage, m, A, Eigenfaces);

% Output Results
SelectedImage = strcat(TrainDatabasePath,'\',OutputName);
SelectedImage = imread(SelectedImage);
imshow(im)
title('Test Image');
figure,imshow(SelectedImage);
title('Equivalent Image');
str = strcat('Matched image is :  ',OutputName);
disp(str)
