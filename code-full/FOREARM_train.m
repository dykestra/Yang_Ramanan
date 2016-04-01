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
% training
model = trainmodel(name,pos,neg,K,pa,sbin);
