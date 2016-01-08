clc; close all; clear;
globals;
name = 'BUFFY';
% --------------------
% specify model parameters
% number of mixtures for 18 parts
K = [6 6 6 6 6 6 6 6 6 6 ...
         6 6 6 6 6 6 6 6]; 
% Tree structure for 18 parts: pa(i) is the parent of part i
% This structure is implicity assumed during data preparation
% (BUFFY_data.m) and evaluation (BUFFY_eval_pcp)
pa = [0 1 2 3 4 5 6 3 8 9 2 11 12 13 14 11 16 17]; 
% Spatial resolution of HOG cell, interms of pixel width and hieght
% The BUFFY dataset contains low-res people, so we use low-res parts
sbin = 8;
% --------------------
% Prepare training and testing images and part bounding boxes
% You will need to write custom *_data() functions for your own dataset
[pos neg test] = BUFFY_data(name);
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
apk = BUFFY_eval_apk(boxes,test);
meanapk = mean(apk);
fprintf('mean APK = %.1f\n',meanapk*100);
fprintf('Keypoints & Head & Shou & Elbo & Wris & Hip\n');
fprintf('APK       '); fprintf('& %.1f ',apk*100); fprintf('\n');
% --------------------
% testing phase 2
% pose estimation given ground truth human box
model.thresh = min(model.thresh,-2);
boxes_gtbox = testmodel_gtbox(name,model,test,suffix);
% --------------------
% evaluation 2: percentage of correct keypoints
% You will need to write your own PCK evaluation code for your data structure
pck = BUFFY_eval_pck(boxes_gtbox,test);
meanpck = mean(pck);
fprintf('mean PCK = %.1f\n',meanpck*100); 
fprintf('Keypoints & Head & Shou & Elbo & Wris & Hip  & Knee & Ankle\n');
fprintf('PCK       '); fprintf('& %.1f ',pck*100); fprintf('\n');
% --------------------
% visualization
figure(1);
visualizemodel(model);
figure(2);
visualizeskeleton(model);
demoimid = 1;
im  = imread(test(demoimid).im);
colorset = {'g','g','y','r','r','r','r','y','y','y','y','b','b','b','b','y','y','y'};
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
