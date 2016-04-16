function write_ljson(points, filename, version)
% write an Nx2 array of points to a PTS file

N = length(points);

if nargin < 3
    version = 1;
end

landmarks.points = points;
landmarks.connectivity = {};

label.label = 'all';
label.mask = 0:length(points)-1;
labels{1} = label;

data.landmarks = landmarks;
data.labels = labels;
data.version = version;

savejson('',data,filename);

end

