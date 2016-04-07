function [apk,prec,rec,fp] = FOREARM_eval_apk(name,suffix,boxes,test)
globals;
if nargin < 3
    try
        load([cachedir name '_boxes_' suffix]);
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
% Model with N keypoints
N = floor(size(boxes{1},2)/4);
I = 1:N;
A = ones(1,N);
Transback = full(sparse(I,I,A,N,N));

% -------------------
% count the total number of candidates
numca = 0;
for n = 1:length(test)
  numca = numca + size(boxes{n},1);
end

% -------------------
% generate candidate joints
ca.point = []; ca.fr = []; ca.score = [];
ca(numca) = ca;
cnt = 0;
for n = 1:length(test)
  if isempty(boxes{n})
    continue;
  end
	box = boxes{n};
  b = box(:,1:floor(size(box, 2)/4)*4);
  b = reshape(b,size(b,1),4,size(b,2)/4);
  b = permute(b,[1 3 2]);
  bx = .5*b(:,:,1) + .5*b(:,:,3);
  by = .5*b(:,:,2) + .5*b(:,:,4);
  for i = 1:size(b,1)
    cnt = cnt + 1;
    ca(cnt).point = Transback * [bx(i,:)' by(i,:)'];
    ca(cnt).fr = n;
    ca(cnt).score = box(i,end);
  end
end

% -------------------
% generate ground truth stick
for n = 1:length(test)
  gt(n).numgt = 1;
  gt(n).point = test(n).point;
  gt(n).scale = norm(gt(n).point(1,:)-gt(n).point(3,:)); % use (hand?) size as the scale
  gt(n).det = 0;
end

numpoint = size(gt(1).point,1);
for k = 1:numpoint
  ca_p = ca;
  gt_p = gt;
  for n = 1:numca
    ca_p(n).point = ca(n).point(k,:);
  end
  for n = 1:length(test)
    gt_p(n).point = gt(n).point(k,:);
  end
  [apk(k) prec{k} rec{k} fp(k)] = eval_apk(ca_p,gt_p);
end

meanapk = mean(apk);
fprintf('mean APK = %.1f\n',meanapk*100);
save([cachedir name '_apk_' suffix], 'apk','prec','rec','fp');

end

