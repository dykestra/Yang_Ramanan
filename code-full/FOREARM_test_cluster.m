function FOREARM_test_cluster(batch_no, gt)
% Submit test jobs to cluster in batches of 20

% HOW TO SUBMIT:
% batch_no = 1:18 or 19
% gt = 1 to use ground truth bounding box 
%% set up cluster job
  globals;

  cluster = parcluster('beehive');
  djob = cluster.createJob(...
      'AdditionalPaths',...
      {'\\hci3.doc.ic.ac.uk\hmi\projects\nb1712\Yang_Ramanan\code-full'...
       '\\hci3.doc.ic.ac.uk\hmi\projects\nb1712\Yang_Ramanan\code-full\cache'...
       '\\hci3.doc.ic.ac.uk\hmi\projects\nb1712\Yang_Ramanan\code-full\detection'...
       '\\hci3.doc.ic.ac.uk\hmi\projects\nb1712\Yang_Ramanan\code-full\learning'...
       '\\hci3.doc.ic.ac.uk\hmi\projects\nb1712\Yang_Ramanan\code-full\mex_unix'});

  djob.AutoAttachFiles = false;
  
  
    %% preliminary code

    name = 'FOREARM_ROT';
    % --------------------
    % specify model parameters
    % specify mix mixtures per part, for N parts
    N = 18
    mix = 1
    [K, ~] = get_K_pa(N,mix);

    % Spatial resolution of HOG cell, interms of pixel width and hieght
    % The FOREARM dataset contains low-res people, so we use low-res parts
    sbin = 4
    % --------------------
    % Prepare training and testing images and part bounding boxes
    % You will need to write custom *_data() functions for your own dataset
    [~, ~, test] = FOREARM_data(name, mix);

    % --------------------
    % load model from cache
    suffix = [num2str(K(1)) '_' num2str(length(K))];
    cls = [name '_final_' suffix];
    load([cachedir cls]);
    
    % Batch parameters
    batch_size = 20;
    start = (batch_no-1)*batch_size + 1;
    finish = min(start + batch_size - 1, length(test));

    %% --------------------
    % testing phase 1
    % human detection + pose estimation
    model.thresh = min(model.thresh,-2);
    if ~gt
      for i = start:finish
        djob.createTask(@test_one, 1, {name, model, test(i), i});
      end
    end
    %% --------------------
    % testing phase 2
    % pose estimation given ground truth human box
    model.thresh = min(model.thresh,-2);
    if gt
      for i = start:finish
        djob.createTask(@test_one_gtbox, 1, {name, model, test(i), i});
      end
    end
    %% ---------------------
      submit(djob);

    % How to check on job:
    % c = parcluster('beehive');
    % c.Jobs(your_id) %% access your job
    % 
    % at any point you can collect the finished jobs by
    % c.Jobs(your_id).fetchOutputs;
    
    % ACCUMULATE RESULTS
    % cls = [name '_boxes_' suffix];
    % load([cachedir cls]);
    % boxes_batch = c.Jobs(your_id).fetchOutputs';
    % boxes = [boxes, boxes_batch];
    % save([cachedir '_boxes_' suffix], 'boxes');
end