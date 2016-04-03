function CLUSTERTEST()
  %% set up cluster job      'NumWorkersRange',[1 20],...
  clc; close all; clear;
  globals;
  
  cluster = parcluster('local');
  djob = cluster.createJob(...
      'AdditionalPaths',...
      {'detection'});
  djob.AutoAttachFiles = false;
  
  A = 80;
  for i = 1:10
      B = i;
      C = randi(10);
      djob.createTask(@dummy_task, 1, {A, B, C});
  end
  
  submit(djob);
  wait(djob);
  data = fetchOutputs(djob)';
  save([cachedir 'dummy_results'], 'data');
end

