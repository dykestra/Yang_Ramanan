function boxes = testmodel(name,model,test,suffix)
% boxes = testmodel(name,model,test,suffix)
% Returns candidate bounding boxes after non-maximum suppression

globals;

try
  load([cachedir name '_boxes_' suffix]);
catch
  boxes = cell(1,length(test));
  for i = 1:length(test)
     boxes{i} = test_one(name, model,test(i),i);
  end

  if nargin < 4
    suffix = [];
  end
  save([cachedir name '_boxes_' suffix], 'boxes','model');
end
