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
[pos, neg, test] = FOREARM_data(name, mix);
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
% additional nms 
for i = 1:length(test)
  boxes{i} = nms(boxes{i},0.3,3);
end

% --------------------
% evaluation 1: average precision of keypoints
% You will need to write your own APK evaluation code for your data structure
[apk,prec,rec,fp] = FOREARM_eval_apk(boxes,test);
figure(1);
scatter(fp,apk,'filled');
fp_marg = range(fp)*0.1;
apk_marg = range(apk)*0.1;
axis([min(fp)-fp_marg, max(fp)+fp_marg, min(apk)-apk_marg, max(apk)+apk_marg])
xlabel('FP'); ylabel('APK');
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

% VISUALISE MODEL
%figure(2);
%visualizemodel(model);
%figure(3);
%visualizeskeleton(model);

% VISUALISE DETECTIONS
nVis = 10;
demoimids = randi(length(test),[1,nVis]);
figno = 4;
for i = 1:length(demoimids)
    demoimid = demoimids(i);
    im = imread(test(demoimid).im);

    colours = ['g','y','r','m','b','c'];
    colorset = cell(1,N);
    for i = 1:N
       colorset{i} = colours(randi([1,size(colours,2)])); 
    end
    box = boxes{demoimid};
    % show all detections
    figure(figno);
    subplot(1,2,1); showboxes(im,box,colorset);
    title(demoimid);
    subplot(1,2,2); showskeletons(im,box,colorset,model.pa);
    % show best detection overlap with ground truth box
    box = boxes_gtbox{demoimid};
    figure(figno+1);
    subplot(1,2,1); showboxes(im,box,colorset);
    title(demoimid);
    subplot(1,2,2); showskeletons(im,box,colorset,model.pa);
    figno = figno + 2;
end
    
end

