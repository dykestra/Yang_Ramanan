function pck = FOREARM_eval_pck(name, suffix, boxes, test )
globals;
if nargin < 3
    try
        load([cachedir name '_boxes_gtbox_' suffix]);
    catch
        error('Results file not found: could not load "boxes"');
    end
end
if nargin < 4
    try
        load([cachedir name '_data_' suffix]);
    catch
        error('Data file not found: could not load "test"');
    end
end
% -------------------
% generate candidate keypoint locations
% model with N keypoints
N = floor(size(boxes{1},2)/4);
I = 1:N;
A = ones(1,N);
Transback = full(sparse(I,I,A,N,N));

for n = 1:length(test)
  ca(n).point = [];
  if isempty(boxes{n})
    continue;
  end
  box = boxes{n};
  b = box(1:floor(size(box, 2)/4)*4);
  b = reshape(b,4,size(b,2)/4);
  bx = .5*b(1,:) + .5*b(3,:);
  by = .5*b(2,:) + .5*b(4,:);
  ca(n).point = Transback * [bx' by'];
end

% -------------------
% generate ground truth keypoint locations
for n = 1:length(test)
  gt(n).point = test(n).point;
  gt(n).scale = norm(gt(n).point(1,:)-gt(n).point(3,:)); % use (hand?) size as the scale
end

pck = eval_pck(ca,gt);
meanpck = mean(pck);
fprintf('mean PCK = %.1f\n',meanpck*100);
save([cachedir name '_pck_' suffix], 'pck');
end

