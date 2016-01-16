function [ pos, neg, test ] = FOREARM_data( name )
% this function is very dataset specific, you need to modify the code if
% you want to apply the pose algorithm on some other dataset

% it converts the various data format of different dataset into unique
% format for pose detection 
% the unique format for pose detection contains below data structure
%   pos:
%     pos(i).im: filename for the image containing i-th human 
%     pos(i).point: pose keypoints for the i-th human
%   neg:
%     neg(i).im: filename for the image contraining no human
%   test:
%     test(i).im: filename for i-th testing image
% This function also prepares flipped images and slightly rotated images for training.

globals;

cls = [name '_data'];
try
	load([cachedir cls]);
catch
   
    test_range = 0:86;
    pos_range = 0:891;
    trainfrs_neg = 615:1832;  % training frames for negative
    
  % -------------------
  % grab positive annotation and image information
    posims = 'FOREARM/training_cropped/%.4d.png';
    pospoints = 'FOREARM/training_cropped/%.4d.pts';
    pos = [];
    numpos = 0;
    for fr = pos_range
        numpos = numpos + 1;
        pos(numpos).im = sprintf(posims,fr);
        pos(numpos).point = read_points(sprintf(pospoints,fr));
    end
  
  % -------------------
  % grab neagtive image information
	negims = 'INRIA/%.5d.jpg';
	neg = [];
	numneg = 0;
    for fr = trainfrs_neg
      numneg = numneg + 1;
      neg(numneg).im = sprintf(negims,fr);
    end
    
  % -------------------
  % grab testing image information
    testims = 'FOREARM/testing_rotated/%.4d.png';
    testpoints = 'FOREARM/testing_rotated/%.4d.pts';
    test = [];
    numtest = 0;
    for fr = test_range
        numtest = numtest + 1;
        test(numtest).im = sprintf(testims,fr);
        test(numtest).point = read_points(sprintf(testpoints,fr));
    end
    
  save([cachedir cls],'pos','neg','test')
end

end

% Read point data from file into 29x2 array
function [points] = read_points(file)

    N = 3;
    points = zeros(N,2);
    
    % Open file
    fid = fopen(file, 'rt');
    if fid < 1,
       error([' Can not open file ', file]);   
    end

    % Skip preamble
    c = '';
    while ~strcmp(c,'{'),
        c = fscanf(fid, '%c', 1);
    end
    
    % Read point data into array with suitable ordering
    % tree structure requires (pa(i) < i) for all i
    % reordering of point data:
    % [1 16 17 18 19 20 21 22 23 24 2 25 26 27 28 29 15 14 1 12 11 10 19 8
    % 7 6 5 4 3]
    points(1,:) = fscanf(fid, '%f', 2);
    points(11,:) = fscanf(fid, '%f', 2);
    for i = 29:-1:17
        points(i,:) = fscanf(fid, '%f', 2);
    end
    for i = 2:10
        points(i,:) = fscanf(fid, '%f', 2);
    end
    for i = 12:16
        points(i,:) = fscanf(fid, '%f', 2);
    end
    
    % Cut down version: take every other part
    points2 = zeros(14,2);
    for i = 1:14
        points2(i,:) = points(2*i,:);
    end
    points = points2;

    % Close file
    fclose(fid);
end
