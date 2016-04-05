function [ pos, neg, test ] = FOREARM_data( name, mix )
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

cls = [name '_data_mix_' num2str(mix)];
try
    load([cachedir cls]);
catch
      
    %[pos, test] = load_original();
    
    if (mix == 1)
        [pos, test] = load_1_mix();
    else 
        [pos, test] = load_mult_mix(mix);
    end
    
    % -------------------
    % grab neagtive image information
    trainfrs_neg = 615:1832;  % training frames for negative
    negims = 'INRIA/%.5d.jpg';
    neg = [];
    numneg = 0;
    for fr = trainfrs_neg
        numneg = numneg + 1;
        neg(numneg).im = sprintf(negims,fr);
    end
    
    save([cachedir cls],'pos','neg','test')
end

end

% ORIGINAL FOREARM SET
function [pos, test] = load_original()
    grab positive annotation and image information
    posims = 'FOREARM/training_cropped/%.4d.png';
    pospoints = 'FOREARM/training_cropped/%.4d.pts';
    numpos = 0;
    for fr = 1:size(posims)
        numpos = numpos + 1;
        pos(numpos).im = sprintf(posims,fr);
        pos(numpos).point = read_points(sprintf(pospoints,fr));
    end

    testims = 'FOREARM/testing_rotated/%.4d.png';
    testpoints = 'FOREARM/testing_rotated/%.4d.pts';
    test = [];
    numtest = 0;
     for fr = 1:size(testims)
         numtest = numtest + 1;
         test(numtest).im = sprintf(testims,fr);
         test(numtest).point = read_points(sprintf(testpoints,fr));
     end
     test = pos(1:500);
end

% ROTATED TO SAME ORIENTATION
function [pos, test] = load_1_mix()
    train_dir = 'FOREARM/Rotated/training/';
    pos = [];
    fr = 1;
    dirData = dir(train_dir);      %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    d = {dirData(~dirIndex).name}';  %'# Get a list of the files
    for i = 1:2:length(d)
       pos(fr).im = strcat(train_dir, d{i});
       pos(fr).point = read_points(strcat(train_dir, d{i+1}));
       fr = fr + 1;
    end

    test_dir = 'FOREARM/Rotated/testing/';
    test = [];
    fr = 1;
    dirData = dir(test_dir);      
    dirIndex = [dirData.isdir];  
    d = {dirData(~dirIndex).name}'; 
    for i = 1:2:length(d)
        test(fr).im = strcat(test_dir, d{i});
        test(fr).point = read_points(strcat(test_dir, d{i+1}));
        fr = fr + 1;
    end
end

% CLUSTERS OF ORIENTATIONS
function [pos, test] = load_mult_mix(mix)
    deg = 360/mix;
    train_dir = 'FOREARM/Rotated/training/';
    pos = [];
    fr = 1;
    cluster = 1;
    for theta = 0:deg:330
        angle_dir = [train_dir num2str(theta) '/'];
        d = dir(angle_dir);
        for i = 3:2:length(d)
           pos(fr).im = strcat(angle_dir, d(i).name);
           pos(fr).point = read_points(strcat(angle_dir, d(i+1).name));
           pos(fr).mix = cluster;
           fr = fr + 1;
        end
        cluster = cluster + 1;
    end
    
    test_dir = 'FOREARM/Rotated/testing/';
    test = [];
    fr = 1;
    for theta = 0:deg:330
        angle_dir = [test_dir num2str(theta) '/'];
        d = dir(angle_dir);
        for i = 3:2:length(d)
            test(fr).im = strcat(angle_dir, d(i).name);
            test(fr).point = read_points(strcat(angle_dir, d(i+1).name));
            fr = fr + 1;
        end
    end
end

% Read point data from file into Nx2 array
function [points] = read_points(file)

N = 37;

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
points = read_with_reordering(fid, N, 1);

% Close file
fclose(fid);
end

% read points in custom order
% halve=1 if every other point should be taken
function points = read_with_reordering(fid, N, halve)

    % 29 PART MODEL
    if (N == 29)
        % FULL MODEL, reordering of point data:
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
    % 37 PART MODEL    
    elseif (N == 37)
        % FULL MODEL, reordering of data:
        % [1 2 3 4 5 6 7 8 9 10 11 23 22 21 20 19 18 17 16 15 14 13 12 24 25 26
        %  27 28 29 30 31 32 33 34 35 36 37]
        for i = 1:11
            points(i,:) = fscanf(fid, '%f', 2);
        end
        for i = 23:-1:12
            points(i,:) = fscanf(fid, '%f', 2);
        end
        for i = 24:37
            points(i,:) = fscanf(fid, '%f', 2);
        end
    % 37 PART MODEL
    elseif (N == 11)
        % 11 PARTS (skeletal), ordering:
        % [1 2 3 4 5 6 7 8 9 10 11]
        for i = 1:11
            points(i,:) = fscanf(fid, '%f', 2);
        end
    end

    % Cut down version: take every other part
    if halve
        N = floor(N/2);
        points2 = zeros(N,2);
        for i = 1:N
            points2(i,:) = points(2*i,:);
        end
        points = points2;
    end
end

