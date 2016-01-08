function pck = PARSE_eval_pck(boxes,test)

% -------------------
% generate candidate keypoint locations
% Our model produce 26 keypoint locations including joints and their middle points
% But for PARSE evaluation, we will only use the original 14 joints
I = [1  2  3  4  5  6  7  8  9  10 11 12 13 14];
J = [14 12 10 22 24 26 7  5  3  15 17 19 2  1];
A = [1  1  1  1  1  1  1  1  1  1  1  1  1  1];
Transback = full(sparse(I,J,A,14,26));

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
  gt(n).scale = norm(gt(n).point(13,:)-gt(n).point(14,:)); % use face size as the scale
end

pck = eval_pck(ca,gt);
% average left with right and neck with top head
pck = (pck + pck([6 5 4 3 2 1 12 11 10 9 8 7 14 13]))/2;
% change the order to: Head & Shoulder & Elbow & Wrist & Hip & Knee & Ankle
pck = pck([14 9 8 7 3 2 1]);
