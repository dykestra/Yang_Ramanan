function [ box ] = test_one_gtbox(name, model,test_one,i)
% 1) Construct ground-truth bounding box
% 2) Compute all candidates that sufficiently overlap it
% 3) Return highest scoring one  

    fprintf([name ': testing: %d\n'],i);
    im = imread(test_one.im);
    box = detect_fast(im,model,model.thresh);
    x = test_one(i).point(:,1);
    y = test_one(i).point(:,2);
    gtbox = [min(x) min(y) max(x) max(y)];
    box = bestoverlap(box,gtbox,0.3);
end

