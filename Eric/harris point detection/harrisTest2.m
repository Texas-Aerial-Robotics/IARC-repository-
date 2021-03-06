clc; clear all 
close all
%triangleTest.png
%square.jpg
I = rgb2gray(imread('box.jpg'));
[height,width,z1] = size(I);
info = imfinfo('triangleTest.png')
figure(1), imshow(I)
I = double(I);

threshold = .4; 

sigma = (6-1)/3;
radius = 10;
size = 2*radius + 1;
g = fspecial('gaussian', max(1, fix(6*sigma)), sigma);
dx = [-1, 0, 1; -1, 0, 1; -1, 0, 1];
dy = dx';

%compute image derivative 
Ix = conv2(I, dx, 'same');
Iy = conv2(I, dy, 'same');

%smooth image
Ix2 = conv2(Ix.^2, g, 'same');
Iy2 = conv2(Iy.^2, g, 'same');
Ixy = conv2(Ix.*Iy, g, 'same');

harris = (Ix2.*Iy2 - Ixy.^2)./((Ix2 + Iy2 + eps)).^2;

%find local maxima
mx = ordfilt2(harris, size.^2, ones(size));

harrisB = (harris == mx) & (harris > threshold);

%plot
[rows, cols] = find(harrisB);

figure(2), imshow(mat2gray(I))
hold on
plot(cols, rows, 'g*', 'markers', 30);


