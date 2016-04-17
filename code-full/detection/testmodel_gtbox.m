function boxes = testmodel_gtbox(name,model,test,suffix)
% Returns highest scoring pose that sufficiently overlaps a detection window
globals;

try
    load([cachedir name '_boxes_gtbox_' suffix]);
catch
    %boxes = cell(1,length(test));
    for i = 1:length(test)
        boxfile = sprintf([cachedir name '_boxes_gtbox_%d_' suffix],i);
        if ~exist([boxfile '.mat'], 'file')
            fprintf([name ': testing: %d/%d\n'],i,length(test));
            box = test_one_gtbox(name, model, test(i), i);
            save(boxfile, 'box');
        end
    end
    
    if nargin < 4
        suffix = [];
    end
    %save([cachedir name '_boxes_gtbox_' suffix], 'boxes','model');
end
