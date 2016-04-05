function [ box ] = test_one_gtbox(name, model,test_one,i)
    fprintf([name ': testing: %d\n'],i);
    im = imread(test_one.im);
    box = detect_fast(im,model,model.thresh);
    x = test(i).point(:,1);
    y = test(i).point(:,2);
    gtbox = [min(x) min(y) max(x) max(y)];
    box = bestoverlap(box,gtbox,0.3);
end

