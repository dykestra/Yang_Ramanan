function FOREARM_demo

clc; close all; clear;
globals;
name = 'FOREARM_ROT';
% --------------------
% specify model parameters
% specify mix mixtures per part, for N parts
N = 18;
mix = 1;
[K, pa] = get_K_pa(N,mix);

% Spatial resolution of HOG cell, interms of pixel width and hieght
% The FOREARM dataset contains low-res people, so we use low-res parts
sbin = 4;
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
[apk,prec,rec,fp] = FOREARM_eval_apk(boxes,test);
figure, plot(apk,fp);
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

colours = ['g','y','r','m','b','c'];
colorset = cell(1,N);
for i = 1:N
   colorset{i} = colours(randi([1,size(colours,2)])); 
end
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
end

function [K, pa] = get_K_pa(N, mix)

    K = repmat(mix,1,N);

    % Define tree structure for N parts: pa(i) is the parent of part i
    if (N == 29)
        % i = 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
        pa = [0 1 2 3 4 5 6 7 8 9 10 10 12 13 14 15 1  17 18 19 20 21 22 23 24 25 ...
              26 27 28];
        % i =  27 28 29
    elseif (N == 14)
        % Cut down tree structure with 14 parts:
        %i =  1 2 3 4 5 6 7 8 9 10 11 12 13 14
        pa = [0 1 2 3 4 5 6 7 1 9 10 11 12 13];

    elseif (N == 37)
        % i =  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
        pa = [0 1 2 3 4 5 6 7 8 9  10 1  12 13 14 15 16 17 18 19 20 21 22 1  24 25 ...
               26 27 28 29 30 31 32 33 34 35 36];
        % i =  27 28 29 30 31 32 33 34 35 36 37
    elseif (N == 18)
        %Cut down tree with 18 parts:
        %i =  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
        pa = [0 1 2 3 4 1 6 7 8 9  10 1 12  13 14 15 16 17];
    elseif (N == 11)
        % 11 part skeletal model
        pa = [0 1 2 3 4 5 6 7 8 9  10];
    end
end