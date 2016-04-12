function points = read_pts(file)
% Read Nx2 array of points from pts file

% Open file
fid = fopen(file, 'rt');

if fid < 1,
    error([' Can not open file ', file]);
end

% Skip "version" line
fgetl(fid);

% Read "n_points" line
N = fscanf(fid, 'n_points: %d',1);

% Skip rest of preamble
c = '';
while ~strcmp(c,'{'),
    c = fscanf(fid, '%c', 1);
end

% read points sequentially
points = [];
for i = 1:N
    points(i,:) = fscanf(fid, '%f', 2);
end

% Close file
fclose(fid);
end
