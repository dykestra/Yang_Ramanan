function FOREARM_demo
% Complete demo script for forearm model including:
% 1. loading data
% 2. model training
% 3. testing phase 1 (no ground truth box)
% 4. APK evaluation
% 5. testing phase 2 (with grount truth box)
% 6. PCK evaluation
% 7. Visualisation of results

clc; close all; clear;
globals;
name = 'FOREARM_ROT';

%% --------------------
% specify model parameters
% specify mix mixtures per part, for N parts
N = 18;
mix = 12;
[K, pa] = get_K_pa(N,mix);

% Spatial resolution of HOG cell, interms of pixel width and hieght
% The FOREARM dataset contains low-res people, so we use low-res parts
sbin = 4;

%% --------------------
% Prepare training and testing images and part bounding boxes
% You will need to write custom *_data() functions for your own dataset
suffix = [num2str(mix) '_' num2str(N)];
[pos, neg, test] = FOREARM_data(name, suffix, mix);
pos = point2box(pos,pa);

%% --------------------
% training
model = trainmodel(name,pos,neg,K,pa,sbin);

%% --------------------
% testing phase 1
% human detection + pose estimation
model.thresh = min(model.thresh,-2);
boxes = testmodel(name,model,test,suffix);
% additional nms
for i = 1:length(test)
    boxes{i} = nms(boxes{i},0.3,3);
end

%% --------------------
% evaluation 1: average precision of keypoints
% You will need to write your own APK evaluation code for your data structure
[apk,prec,rec] = FOREARM_eval_apk(name,suffix,boxes,test);

% Plotting Precision-Recall curves
figure(1);
for i=1:length(prec)
    plot(rec{1,i},prec{1,i});hold on;
end
axis([0,1,0,1]);
xlabel('Recall'); ylabel('Precision');

fprintf('Keypoints: '); fprintf(' &  %.2d ',1:N); fprintf('\n');
fprintf('APK         '); fprintf('& %.1f ',apk*100); fprintf('\n');


%% --------------------
% testing phase 2
% pose estimation given ground truth human box
model.thresh = min(model.thresh,-2);
boxes_gtbox = testmodel_gtbox(name,model,test,suffix);

%% --------------------
% evaluation 2: percentage of correct keypoints
% You will need to write your own PCK evaluation code for your data structure
pck = FOREARM_eval_pck(name,suffix,boxes_gtbox,test);
fprintf('Keypoints: '); fprintf(' &  %.2d ',1:N); fprintf('\n');
fprintf('PCK         '); fprintf('& %.1f ',pck*100); fprintf('\n');

%% --------------------
% visualization

% VISUALISE MODEL
figure(2);
visualizemodel(model);
figure(3);
visualizeskeleton(model);

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
    title('Boxes');
    subplot(1,2,2); showskeletons(im,box,colorset,model.pa);
    title('Skeleton');
    make_title(demoimid, 'without GT box');
    
    % show best detection overlap with ground truth box
    box = boxes_gtbox{demoimid};
    figure(figno+1);
    subplot(1,2,1); showboxes(im,box,colorset);
    title('Boxes');
    subplot(1,2,2); showskeletons(im,box,colorset,model.pa);
    title('Skeleton');
    make_title(demoimid, 'with GT box');
    figno = figno + 2;
end

end

function make_title(demoimid, rest)
    annotation('textbox', [0 0.9 1 0.1], ...
    'String', [sprintf('Image No: %d, ',demoimid) rest], ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center')
end