function write_points(points, filename, version)
% write an Nx2 array of points to a PTS file

N = length(points);

if nargin < 3
    version = 1;
end

fid = fopen(filename, 'w');
if fid < 1,
    error([' Can not open file ', file]);
end

% write preamble
fprintf(fid, 'version: %d\n', version);
fprintf(fid, 'n_points: %d\n', N);
fprintf(fid, '{\n');

% write points
for i=1:N
    fprintf(fid, '%.2f %.2f\n', points(i,1), points(i,2));
end

fprintf(fid, '}');
fclose(fid);

end

