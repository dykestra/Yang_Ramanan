% Read point data from file into Nx2 array
function [points] = read_points(file, reorder, halve)
% file = filename as string
% reorder = 1 if pre-defined reordering should be used
% halve = 1 if half the points should be returned

if nargin < 3
    halve = 0;
end
if nargin < 2
    reorder = 0;
end

[~,~,ext] = fileparts(file);
if strcmp(ext, '.pts')
    points = read_pts(file);
elseif strcmp(ext, '.ljson')
    points = read_ljson(file);
else
    error([' Unrecognised extension: ', ext]);
end

% Read point data into array with suitable ordering
% tree structure requires (pa(i) < i) for all i
if reorder
    points = apply_reordering(points);
end

if halve
    points = halve_points(points);
end

end

function points = apply_reordering(points)
N = length(points);
% apply model-specific reordering
if N == 29
    idx = [1 16 17 18 19 20 21 22 23 24 2 25 26 27 28 29 ...
        15 14 13 12 11 10 19 8 7 6 5 4 3];
elseif N == 37
    idx = [1 2 3 4 5 6 7 8 9 10 11 23 22 21 20 19 18 17 16 15 14 13 12 ...
        24 25 26 27 28 29 30 31 32 33 34 35 36 37];
else
    error('No reordering specified for %d parts',N);
end
points = points(idx(:),:);
end

function points = halve_points(points)
N = floor(length(points)/2);
points2 = zeros(N,2);
for i = 1:N
    points2(i,:) = points(2*i,:);
end
points = points2;
end