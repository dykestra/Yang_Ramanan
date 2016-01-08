function [pos neg test] = BUFFY_data(name)
% this function is very dataset specific, you need to modify the code if
% you want to apply the pose algorithm on some other dataset

% it converts the various data format of different dataset into unique
% format for pose detection 
% the unique format for pose detection contains below data structure
%   pos:
%     pos(i).im: filename for the image containing i-th human 
%     pos(i).point: pose keypoints for the i-th human
%   neg:
%     neg(i).im: filename for the image contraining no human
%   test:
%     test(i).im: filename for i-th testing image
% This function also prepares flipped images and slightly rotated images for training.

globals;

cls = [name '_data'];
try
	load([cachedir cls]);
catch
	posanno   = 'BUFFY/data/buffy_s5e%d_sticks.txt';
	posims    = 'BUFFY/images/buffy_s5e%d_original/%.6d.jpg';
	labelfile = 'BUFFY/labels/buffy_s5e%d_labels.mat';
  
  trainepi = [3 4];   % training episodes
  testepi  = [2 5 6]; % testing  episodes
	trainfrs_neg = 615:1832;  % training frames for negative

  % -------------------
  % grab positive annotation and image information
  pos = [];
  numpos = 0;
  for e = trainepi
    lf = ReadStickmenAnnotationTxt(sprintf(posanno,e));
    load(sprintf(labelfile,e));
    for n = 1:length(lf)
      numpos = numpos + 1;
      pos(numpos).im = sprintf(posims,e,lf(n).frame);
      pos(numpos).point = labels(:,:,n);
    end
  end

  % -------------------
  % flip positive training images
  posims_flip = [cachedir 'imflip/BUFFY%.6d.jpg'];
  for n = 1:length(pos)
    im = imread(pos(n).im);
    imwrite(im(:,end:-1:1,:),sprintf(posims_flip,n));
  end

  % -------------------
  % flip labels for the flipped positive training images
  % mirror property for the keypoint, please check your annotation for your
  % own dataset
	mirror = [1 2 5 6 3 4 8 7 10 9]; % for flipping original data
  for n = 1:length(pos)
    im = imread(pos(n).im);
    width = size(im,2);
    numpos = numpos + 1;
    pos(numpos).im = sprintf(posims_flip,n);
    pos(numpos).point(mirror,1) = width - pos(n).point(:,1) + 1;
    pos(numpos).point(mirror,2) = pos(n).point(:,2);
  end
  
	% -------------------
  % create ground truth keypoints for model training
  % the model may use any set of keypoints not restricted to the keypoints
  % annotated in the dataset
  % for example, we do not use the original 10 keypoints for model training,
  % instead, we generate another 18 keypoints which cover more of space of
  % the human body
	I = [1  2  3  4   4   5  6   6   7  8   8   9   9   10 ...
						 11 12  12  13 14  14  15 16  16  17  17  18];
	J = [1  2  3  3   4   4  4   7   7  3   9   3   9   9 ...
						 5  5   6   6  6   8   8  5   10  5   10  10];
	A = [1  1  1  1/2 1/2 1  1/2 1/2 1  2/3 1/3 1/3 2/3 1 ...
						 1  1/2 1/2 1  1/2 1/2 1  2/3 1/3 1/3 2/3 1];
	Trans = full(sparse(I,J,A,18,10));
  
	for n = 1:length(pos)
    pos(n).point = Trans * pos(n).point; % liear combination
  end

	% -------------------
	% grab neagtive image information
	negims = 'INRIA/%.5d.jpg';
	neg = [];
	numneg = 0;
	for fr = trainfrs_neg
    numneg = numneg + 1;
    neg(numneg).im = sprintf(negims,fr);
	end
  
	% -------------------
  % grab testing image information
  test = [];
  numtest = 0;
  for e = testepi
    lf = ReadStickmenAnnotationTxt(sprintf(posanno,e));
    load(sprintf(labelfile,e));
    for n = 1:length(lf)
      numtest = numtest + 1;
      test(numtest).epi = e;
      test(numtest).frame = lf(n).frame;
      test(numtest).im = sprintf(posims,e,lf(n).frame);
      test(numtest).point = labels(:,:,n);
    end
  end

	save([cachedir cls],'pos','neg','test');
end
