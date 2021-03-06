clc; clear all
close all
% I1 = [1,1,1,1,1,1,1];
% I2 = [1,1,0,0,1,1,1];
% I3 = [1,0,1,1,0,1,1];
% I4 = [1,0,1,1,1,0,1];
% I5 = [1,1,0,0,0,1,1];
% I6 = [1,1,1,1,1,1,1];
% I = [I1; I2; I3; I4; I5; I6];
IOG = imread('multiTargets.jpg');
I = rgb2gray(IOG);
I = double(I);

I = detectEdges(I);
figure(1), imshow(mat2gray(I))



[height, width] =  size(I);
direction = [8, 1, 2; 7, 9, 3; 6, 5, 4];
% directoin of A2L  1, 2, 3... 8 
add2Last = [-1, 0; -1, 1; 0, 1; 1,1; 1,0; 1,-1; 0,-1; -1,-1];
points = zeros(1,2);
numContours = 0;

stop = false;
cFill = zeros(height, width, 10);
for row=1:height
    for col=1:width
        lastMove = 7;
        
        if I(row, col) == 0
            %start new contour
            numContours = numContours +1;
            points = zeros(1,2);
            numPoints =1;
            points(numPoints,:) = [row, col];
            
            for i=1:10000
            
                if points(numPoints,1) == points(1,1) && points(numPoints,2) == points(1,2) && numPoints > 1 
                    stop =true
                    break
                end
                msub = I(points(numPoints,1)-1:points(numPoints,1)+1, points(numPoints,2)-1:points(numPoints,2)+1);
                %for purpose of testing
                %order the submatrix in the order of the clockwise search
                for k=1:9
                    if k ~= 5
                        pmSub(direction(k)) = msub(k);
                    end
                    
                end
                
                %assign find and assign next point to the contour
                for p=0:7
                    
                    if pmSub(lastMove +p) == 0
                        numPoints = numPoints + 1;
                        points(numPoints,:) =  points(numPoints-1,:) + add2Last(lastMove+p,:);
                        %assign new last move
                        lastMove = lastMove +p;
                        if lastMove == 1 || lastMove == 2
                            lMN = 7;
                        end
                        if lastMove == 3 || lastMove == 4
                            lMN = 1;
                        end
                        if lastMove == 5 || lastMove == 6
                            lMN = 3;
                        end
                        if lastMove == 7 || lastMove == 8
                            lMN = 5;
                        end
                        lastMove = lMN;
                        
                        break
                    end
                    
                    if lastMove+p == 8
                        lastMove = -p;
                    end
                    
                end
                
            end %end while
            contour = zeros(height, width);
            
            for k=1:length(points)
                contour(points(k,1), points(k,2)) =1;
            end
            
            %fill contour level
            cFill(:,:,numContours) = imfill((contour),'holes');
            for r=1:height
               for c=1:width
                   if cFill(r,c, numContours) == 1
                      I(r,c) = 1; 
                   end
               end
            end
            points
            stop = false;
        end
        if stop == true
            break
        end
    end
    if stop == true
        break
    end
end

p = zeros(1,2);
for k=1:numContours
   [p(k,:)]=findcenter(cFill(:,:,k)); 
end


%figure(2), imshow(mat2gray(contour(:,:,1)))
figure(3), imshow(mat2gray(cFill(:,:,1)))
figure(4), imshow(mat2gray(I))
figure(5), imshow(mat2gray(cFill(:,:,2)))
figure(6), imshow(IOG)
hold on
for k=1:numContours
plot(round(p(k,2)),round(p(k,1)),'*b')
end

msub
pmSub


