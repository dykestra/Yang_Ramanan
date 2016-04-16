function ljson2pts(infile,outfile)
% read points from ljson infile and write to pts outfile


[dir,name,ext] = fileparts(infile);
if ~strcmp(ext,'.ljson')
    error(['Unexpected extension: ' ext]);
end

if nargin < 2
    outfile = [dir '/' name '.pts'];
end
    
points = read_points(infile); % no reordering or halving
write_pts(points, outfile);
end

