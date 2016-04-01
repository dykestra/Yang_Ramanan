clc; close all; clear;
globals;
name = 'FOREARM_ROT';
% --------------------
% specify model parameters
% specify mix mixtures per part, for N parts
N = 18
mix = 1
[K, pa] = get_K_pa(N,mix);

% Spatial resolution of HOG cell, interms of pixel width and hieght
% The FOREARM dataset contains low-res people, so we use low-res parts
sbin = 4
% --------------------
% Prepare training and testing images and part bounding boxes
% You will need to write custom *_data() functions for your own dataset
[pos, neg, test] = FOREARM_data(name, mix);
pos = point2box(pos,pa);


% --------------------
% load model from cache
cls = [name '_final_' num2str(K')'];
%cls = [name '_final_' num2str(K(1)) '_' num2str(length(K))];
load([cachedir cls]);

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
% testing phase 2
% pose estimation given ground truth human box
model.thresh = min(model.thresh,-2);
boxes_gtbox = testmodel_gtbox(name,model,test,suffix);

