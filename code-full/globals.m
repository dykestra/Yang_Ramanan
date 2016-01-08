% Set up global paths used throughout the code
addpath learning;
addpath detection;
addpath visualization;
addpath evaluation;
if isunix()
  addpath mex_unix;
elseif ispc()
  addpath mex_pc;
end

% directory for caching models, intermediate data, and results
cachedir = 'cache/';
if ~exist(cachedir,'dir')
  mkdir(cachedir);
end

if ~exist([cachedir 'imrotate/'],'dir')
  mkdir([cachedir 'imrotate/']);
end

if ~exist([cachedir 'imflip/'],'dir')
  mkdir([cachedir 'imflip/']);
end

addpath BUFFY;
