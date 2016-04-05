function boxes = testmodel_gtbox(name,model,test,suffix)
% boxes = testmodel_gtbox(name,model,test,suffix)
% Returns highest scoring pose that sufficiently overlaps a detection window
% 1) Construct ground-truth bounding box
% 2) Compute all candidates that sufficiently overlap it
% 3) Return highest scoring one  

globals;

try
  load([cachedir name '_boxes_gtbox_' suffix]);
catch
  boxes = cell(1,length(test));
  for i = 1:length(test)
     boxes{i} = test_one_gtbox(name, model, test(i), i);
  end

  if nargin < 4 
    suffix = [];
  end
  save([cachedir name '_boxes_gtbox_' suffix], 'boxes','model');
end
