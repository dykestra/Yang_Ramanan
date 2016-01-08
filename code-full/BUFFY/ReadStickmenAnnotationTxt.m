function [lF] = ReadStickmenAnnotationTxt(txtfile,optionalfieldname,defaultvalue)
% lF = ReadStickmenAnnotationTxt(txtfile)
% Read annotations in file 'txtfile' and stores them in a struct-array.
% 
% Input:
%  - txtfile containing annotations:
%
% Output:
%  - lF: struct-array with fields:
%      .stickmen.coor: matrix [4, nparts]. lF(k).coor(:,i) --> (x1, y1, x2, y2)' 
%      .optionalfieldname = defaultvalue;
%      if annot file contains frame numbers then .frame field exist of type double (containing a frame number)
%      if annot file contains filenames then .filename field exist of type string (containing an image filename)
%
%
% See also DrawStickmen
%
% MJMJ/2008 changed by Eichner/2009
%

% Open file
fid = fopen(txtfile, 'rt');
if fid < 1,
   error([' Can not open file ', txtfile]);   
end




% Read frames and annotations
nread = 0;
stop = false;
while ~stop,
  [element, count] = fscanf(fid, '%s', 1); % Read element
  if count < 1
    stop = true; 
  else % read annotation
    nread = nread+1;
    
    if isempty(regexp(element,'[a-zA-Z]','once'))
      % frame number
      lF(nread).frame = str2double(element); 
    else
      % filename
      lF(nread).filename = element;
    end
    
    for k = 1:6,
      [lF(nread).stickmen.coor(1:4,k), count] = fscanf(fid, '%f', 4); % Read coordinates for part
      if count < 4,
        error('incomplete annotation');
      end
    end % k
    if nargin > 2
      eval(['lF(nread).' optionalfieldname '=' defaultvalue ';'])
    end
      
   end
end

% Close file
fclose(fid);