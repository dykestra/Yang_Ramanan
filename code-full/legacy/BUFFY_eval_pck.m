function pck = BUFFY_eval_pck(boxes,test)

% -------------------
% generate candidate keypoint locations
% Our model produce 18 keypoint locations including joints and their middle points
% But for BUFFY evaluation, we will only use the original 10 joints
I = [1 2 3 4 5  6  7 8  9  10];
J = [1 2 3 5 11 13 7 15 10 18];
A = [1 1 1 1 1  1  1 1  1  1];
Transback = full(sparse(I,J,A,10,18));

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
  gt(n).scale = norm(gt(n).point(1,:)-gt(n).point(2,:)); % use face size as the scale
end

pck = eval_pck(ca,gt);
% average left with right and neck with top head
pck = (pck + pck([2 1 5 6 8 10 3 4 7 9]))/2;
% change the order to: Head & Shoulder & Elbow & Wrist & Hip & Knee & Ankle
pck = pck([1 3 4 5 7 9]);
