function FOREARM_test(N, mix, sbin)
% Test an existing forearm model with N parts and mix mixtures per part
% sbin = Spatial resolution of HOG cell in terms of pixel width and height
    globals;
    name = 'FOREARM_ROT';
    N
    mix
    sbin
    [K, pa] = get_K_pa(N,mix);

    % --------------------
    % Prepare training and testing images and part bounding boxes
    % You will need to write custom *_data() functions for your own dataset
    suffix = [num2str(mix) '_' num2str(N)];
    [~,~,test] = FOREARM_data(name, suffix, mix);

    % --------------------
    % load model from cache
    cls = [name '_final_' suffix];
    load([cachedir cls]);

    %% --------------------
    % testing phase 1
    % human detection + pose estimation
    model.thresh = min(model.thresh,-2);
    boxes = testmodel(name,model,test,suffix);

    %% --------------------
    % testing phase 2
    % pose estimation given ground truth human box
    model.thresh = min(model.thresh,-2);
    boxes_gtbox = testmodel_gtbox(name,model,test,suffix);
end
