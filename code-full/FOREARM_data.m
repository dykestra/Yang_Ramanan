function [ pos, neg, test ] = FOREARM_data( name, suffix, mix )
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
cls = [name '_data_' suffix];
try
    load([cachedir cls]);
catch
    
    if strcmp(name, 'FOREARM')
        [pos, test] = load_original();
    elseif strcmp(name, 'FOREARM_ROT')
        if (mix == 1)
            [pos, test] = load_1_mix();
        else
            [pos, test] = load_mult_mix(mix);
        end
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
reorder = 1;
halve = 1;
grab positive annotation and image information
posims = 'FOREARM/training_cropped/%.4d.png';
pospoints = 'FOREARM/training_cropped/%.4d.pts';
numpos = 0;
for fr = 1:size(posims)
    numpos = numpos + 1;
    pos(numpos).im = sprintf(posims,fr);
    pos(numpos).point = read_points(sprintf(pospoints,fr), reorder, halve);
end

testims = 'FOREARM/testing_rotated/%.4d.png';
testpoints = 'FOREARM/testing_rotated/%.4d.pts';
test = [];
numtest = 0;
for fr = 1:size(testims)
    numtest = numtest + 1;
    test(numtest).im = sprintf(testims,fr);
    test(numtest).point = read_points(sprintf(testpoints,fr), reorder, halve);
end
test = pos(1:500);
end

% ROTATED TO SAME ORIENTATION
function [pos, test] = load_1_mix()
reorder = 1;
halve = 1;
train_dir = 'FOREARM/Rotated/training/';
pos = [];
fr = 1;
dirData = dir(train_dir);      %# Get the data for the current directory
dirIndex = [dirData.isdir];  %# Find the index for directories
d = {dirData(~dirIndex).name}';  %'# Get a list of the files
for i = 1:2:length(d)
    pos(fr).im = strcat(train_dir, d{i});
    pos(fr).point = read_points(strcat(train_dir, d{i+1}), reorder, halve);
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
    test(fr).point = read_points(strcat(test_dir, d{i+1}), reorder, halve);
    fr = fr + 1;
end
end

% CLUSTERS OF ORIENTATIONS
function [pos, test] = load_mult_mix(mix)
reorder = 1
halve = 1
mirror = 1

deg = 360/mix;
train_dir = 'FOREARM/Rotated/training/';
mirror_dir = 'FOREARM/Mirrored/training/';
pos = [];
fr = 1;
cluster = 1;
for theta = 0:deg:330
%     angle_dir = [train_dir num2str(theta) '/'];
%     d = dir(angle_dir);
%     for i = 3:2:length(d)
%         pos(fr).im = strcat(angle_dir, d(i).name);
%         pos(fr).point = read_points(strcat(angle_dir, d(i+1).name), reorder, halve);
%         pos(fr).mix = cluster;
%         fr = fr + 1;
%     end
    if mirror
        angle_dir = [mirror_dir num2str(theta) '/'];
        d = dir(angle_dir);
        for i = 3:2:length(d)
            pos(fr).im = strcat(angle_dir, d(i).name);
            pos(fr).point = read_points(strcat(angle_dir, d(i+1).name), reorder, halve);
            pos(fr).mix = cluster;
            fr = fr + 1;
        end
    end
    cluster = cluster + 1;
end

% test = load_rotated_testing(reorder, halve);
% test = load_unrotated_testing(reorder, halve);
% test = load_multi_arm(reorder, halve);
% test = load_multi_arm_cropped();
 test = load_bbc_pose();

end

function test = load_rotated_testing(reorder, halve)
test_dir = 'FOREARM/Rotated/testing/';
test = [];
fr = 1;
for theta = 0:deg:330
    angle_dir = [test_dir num2str(theta) '/'];
    d = dir(angle_dir);
    for i = 3:2:length(d)
        test(fr).im = strcat(angle_dir, d(i).name);
        test(fr).point = read_points(strcat(angle_dir, d(i+1).name), reorder, halve);
        fr = fr + 1;
    end
end
end

function test = load_unrotated_testing(reorder, halve)
test_dir = 'FOREARM/Rotated/unrotated_testing/';
test = [];
d = dir(test_dir);
fr = 1;
for i = 3:2:length(d)
    test(fr).im = [test_dir d(i).name];
    test(fr).point = read_points([test_dir d(i+1).name], reorder, halve);
    fr = fr + 1;
end
end

function test = load_multi_arm(reorder, halve)
testdir = 'MultiArm/';
testims = [testdir '%.3d.jpg'];
test = [];
numtest = 0;
testrange = 0:74;
for fr = testrange
    numtest = numtest + 1;
    test(numtest).im = sprintf(testims,fr);
    [~,n,~] = fileparts(test(numtest).im);
    testpoints = [testdir n '_*.jpg_simple37.ljson'];
    d = dir(testpoints);
    for j=1:length(d)
        test(numtest).point(:,:,j) = read_points(d(j).name, reorder, halve);
    end
    test(numtest).numgt = length(d);
end
end

function test = load_multi_arm_cropped()
test_dir = 'MultiArm/cropped_copies/';
dirData = dir(test_dir);      %# Get the data for the current directory
dirIndex = [dirData.isdir];  %# Find the index for directories
d = {dirData(~dirIndex).name}';  %'# Get a list of the files
test = [];
fr = 1;
for i = 1:2:length(d)
    [~,n,~] = fileparts(d{i});
    test(fr).im = [test_dir n '.jpg'];
    test(fr).point = read_points([test_dir n '.pts']);
    fr = fr + 1;
end
end

function test = load_bbc_pose()
test_dir = 'BBC_POSE/4/';
dirData = dir(test_dir);      %# Get the data for the current directory
dirIndex = [dirData.isdir];  %# Find the index for directories
d = {dirData(~dirIndex).name}';  %'# Get a list of the files
test = [];
fr = 1;
for i = 1:3:length(d)
    [~,n,~] = fileparts(d{i});
    test(fr).im = [test_dir n '.jpg'];
    test(fr).point = read_points([test_dir n '.pts']);
    fr = fr + 1;
end
end

function test = load_bbc_pose_full()
test_dir = '/vol/atlas/databases/bbc_pose/bbc_pose/1/';
test = [];
fr = 1;
for i=200:39070
    test(fr).im = [test_dir num2str(i) '.jpg'];
    test(fr).point = read_points([test_dir num2str(i) '.pts']);
    fr = fr + 1;
end
end
