function points = read_ljson(file)
% Read Nx2 array of points from pts file

% Open file
fid = fopen(file, 'rt');

if fid < 1,
    error([' Can not open file ', file]);
end
raw = fread(fid,inf);
str = char(raw');

fclose(fid);

% read point data as 1xN cell of 1x2 cells
data = JSON.parse(str);
point_cell = data.landmarks.points;

% convert point cell into Nx2 array
for i=1:length(point_cell)
    point_cell{1,i} = cell2mat(point_cell{1,i});
end
points = cell2mat(point_cell');

end
