function [apk,prec,rec] = PARSE_eval_apk(boxes,test)

% -------------------
% generate candidate keypoint locations
% Our model produce 26 keypoint locations including joints and their middle points
% But for PARSE evaluation, we will only use the original 14 joints
I = [1  2  3  4  5  6  7  8  9  10 11 12 13 14];
J = [14 12 10 22 24 26 7  5  3  15 17 19 2  1];
A = [1  1  1  1  1  1  1  1  1  1  1  1  1  1];
Transback = full(sparse(I,J,A,14,26));

% -------------------
% count the total number of candidates
numca = 0;
for n = 1:length(test)
  numca = numca + size(boxes{n},1);
end

% -------------------
% generate candidate keypoint locations
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
% generate ground truth keypoint locations
for n = 1:length(test)
  gt(n).numgt = 1;
  gt(n).point = test(n).point;
  gt(n).scale = norm(gt(n).point(13,:)-gt(n).point(14,:)); % use face size as the scale
  gt(n).det = 0;
end

% -------------------
% evaluate precision recall for keypoint marginally 
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
  [apk(k) prec{k} rec{k}] = eval_apk(ca_p,gt_p);
end

% average left with right and neck with top head
apk = (apk + apk([6 5 4 3 2 1 12 11 10 9 8 7 14 13]))/2;
% change the order to: Head & Shoulder & Elbow & Wrist & Hip & Knee & Ankle
apk = apk([14 9 8 7 3 2 1]);
