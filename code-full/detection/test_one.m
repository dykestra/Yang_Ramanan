function [ box ] = test_one(name, model,test_one,i)
% Returns candidate bounding boxes for ONE IMAGE after non-maximum suppression
    im = imread(test_one.im);
    box = detect_fast(im,model,model.thresh);
    box = nms(box,0.7);
end

