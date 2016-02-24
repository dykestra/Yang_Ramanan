clc; close all; clear;
globals;
name = 'FOREARM_ROT';
% --------------------
% specify model parameters
% specify 1 mixture per part for N parts
N = 11;
K = ones(1,N);
%K = repmat(12,1,N);

% Tree structure for 29 parts: pa(i) is the parent of part i
% i = 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
%pa = [0 1 2 3 4 5 6 7 8 9 10 10 12 13 14 15 1  17 18 19 20 21 22 23 24 25 ...
%      26 27 28];
% i =  27 28 29  

% Cut down tree structure with 14 parts:
%i =  1 2 3 4 5 6 7 8 9 10 11 12 13 14
%pa = [0 1 2 3 4 5 6 7 1 9 10 11 12 13];

% i =  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
% pa = [0 1 2 3 4 5 6 7 8 9  10 1  12 13 14 15 16 17 18 19 20 21 22 1  24 25 ...
%       26 27 28 29 30 31 32 33 34 35 36];
 pa = [0 1 2 3 4 5 6 7 8 9  10];

% i =  27 28 29 30 31 32 33 34 35 36 37


% Spatial resolution of HOG cell, interms of pixel width and hieght
% The FOREARM dataset contains low-res people, so we use low-res parts
sbin = 2;
% --------------------
% Prepare training and testing images and part bounding boxes
% You will need to write custom *_data() functions for your own dataset
[pos, neg, test] = FOREARM_data(name);
pos = point2box(pos,pa);
% --------------------
% training
model = trainmodel(name,pos,neg,K,pa,sbin);
% --------------------
% testing phase 1
% human detection + pose estimation
suffix = num2str(K')';
model.thresh = min(model.thresh,-2);
boxes = testmodel(name,model,test,suffix);
% --------------------
% evaluation 1: average precision of keypoints
% You will need to write your own APK evaluation code for your data structure
apk = FOREARM_eval_apk(boxes,test);
meanapk = mean(apk);
fprintf('mean APK = %.1f\n',meanapk*100);
fprintf('Keypoints: '); fprintf(' &  %.2d ',1:14); fprintf('\n');
fprintf('APK         '); fprintf('& %.1f ',apk*100); fprintf('\n');
% --------------------
% testing phase 2
% pose estimation given ground truth human box
model.thresh = min(model.thresh,-2);
boxes_gtbox = testmodel_gtbox(name,model,test,suffix);
% --------------------
% evaluation 2: percentage of correct keypoints
% You will need to write your own PCK evaluation code for your data structure
pck = FOREARM_eval_pck(boxes_gtbox,test);
meanpck = mean(pck);
fprintf('mean PCK = %.1f\n',meanpck*100); 
fprintf('Keypoints: '); fprintf(' &  %.2d ',1:14); fprintf('\n');
fprintf('PCK         '); fprintf('& %.1f ',pck*100); fprintf('\n');
% --------------------
% visualization
figure(1);
visualizemodel(model);
figure(2);
visualizeskeleton(model);
demoimid = 1;
im = imread(test(demoimid).im);

colorset = {'g','g','y','r','r','y','m','m','y','b','b'};
%,'y','c','c'};
box = boxes{demoimid};
% show all detections
figure(3);
subplot(1,2,1); showboxes(im,box,colorset);
subplot(1,2,2); showskeletons(im,box,colorset,model.pa);
% show best detection overlap with ground truth box
box = boxes_gtbox{demoimid};
figure(4);
subplot(1,2,1); showboxes(im,box,colorset);
subplot(1,2,2); showskeletons(im,box,colorset,model.pa);

