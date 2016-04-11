% Read point data from file into Nx2 array
function [points] = read_points(file, reorder, halve)
% file = PTS filename
% reorder = 1 if pre-defined reordering should be used
% halve = 1 if half the points should be returned

if nargin < 3
    halve = 0;
end
if nargin < 2
    reorder = 0;
end

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

% Read point data into array with suitable ordering
% tree structure requires (pa(i) < i) for all i
if reorder
    % read points with specific reodering
    points = read_with_reordering(fid, N, halve);
else
    % read points sequentially
    points = [];
    for i = 1:N
        points(i,:) = fscanf(fid, '%f', 2);
    end
end

% Close file
fclose(fid);
end

% read points in custom order
% halve=1 if every other point should be taken
function points = read_with_reordering(fid, N, halve)

    % 29 PART MODEL
    if (N == 29)
        % FULL MODEL, reordering of point data:
        % [1 16 17 18 19 20 21 22 23 24 2 25 26 27 28 29 15 14 1 12 11 10 19 8
        % 7 6 5 4 3]
        points(1,:) = fscanf(fid, '%f', 2);
        points(11,:) = fscanf(fid, '%f', 2);
        for i = 29:-1:17
            points(i,:) = fscanf(fid, '%f', 2);
        end
        for i = 2:10
            points(i,:) = fscanf(fid, '%f', 2);
        end
        for i = 12:16
            points(i,:) = fscanf(fid, '%f', 2);
        end
    % 37 PART MODEL    
    elseif (N == 37)
        % FULL MODEL, reordering of data:
        % [1 2 3 4 5 6 7 8 9 10 11 23 22 21 20 19 18 17 16 15 14 13 12 24 25 26
        %  27 28 29 30 31 32 33 34 35 36 37]
        for i = 1:11
            points(i,:) = fscanf(fid, '%f', 2);
        end
        for i = 23:-1:12
            points(i,:) = fscanf(fid, '%f', 2);
        end
        for i = 24:37
            points(i,:) = fscanf(fid, '%f', 2);
        end
    end
    % Cut down version: take every other part
    if halve
        N = floor(N/2);
        points2 = zeros(N,2);
        for i = 1:N
            points2(i,:) = points(2*i,:);
        end
        points = points2;
    end
end


