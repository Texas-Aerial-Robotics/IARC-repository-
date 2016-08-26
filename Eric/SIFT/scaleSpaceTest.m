%test scale space
%last modified by Eric Johnson on 8/21/2016
clc; clear all
close all

I = rgb2gray(imread('UTFootball.jpg'));

figure(1), imshow(I)
info = imfinfo('UTFootball.jpg')

[height, width,z] = size(I)

dimension = 11;
count = 1;
ki = sqrt(2);
sigma = 1.6;
shift=-1;
for ii=1:4
    
    for i=1:6
        k = ki^(i+shift);
        [guassMask] = createGuassMaskK(dimension, sigma, k);
        scaleSpace(:,:,count) = conv2(I(:,:,1), guassMask, 'same');
        count = count + 1;
    end
    sigma = sigma*2;
    shift = shift + 2;
end
scaleSpaceL = zeros(height, width, 16);
%perform difference of guassian
 for i=1:2:count-1
        scaleSpaceL(:,:,(i+1)/2) = scaleSpace(:,:,i+1) - scaleSpace(:,:,i);
 end


%show scale space 
count=1;

for ii=1:4
    figure(ii+1)
    for i=1:3
        subplot(3,1,i), imshow((mat2gray(scaleSpaceL(:,:,count))))
        hold on
        count= count+1;
    end
end

%look for extrema 
for
