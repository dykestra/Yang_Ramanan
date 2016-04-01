function rotate
   noldtrain = 600;
   nnewtrain = 300;
   noldtest = 151;
   nnewtest = 220;
   origDir = 'FOREARM/Rotated/testing/';
   
   % load list of image numbers from file
   fid = fopen('FOREARM/Rotated/goodfit.txt');
   Files = {};
   line = fgetl(fid);
   nskip = noldtrain + nnewtrain + noldtest + 1;
   for i =1:nskip
       line = fgetl(fid);
   end
   for i=1:nnewtest
       Files{end+1,1} = line;
       line = fgetl(fid);
   end
   fclose(fid);
   
   %rotate_to_same_angle(Files, origDir);
   rotate_into_clusters(30, Files, origDir);
   
end

function rotate_one(n, deg, origDir, rotDir)
    % retrieve image and landmarks
    img = imread(strcat(origDir, n, '.png'));
    points = read_points(strcat(origDir, n, '.pts'));

    % find angle needed to rotate forearm to desired orientation, deg
    centre = mean(points,1);
    endpoint = points(1,:);
    rotAngle = rotationAngle(deg, centre, endpoint);
    fprintf('Centre: (%.2f, %.2f), Endpoint: (%.2f, %.2f)\n', centre(1), centre(2), endpoint(1), endpoint(2));
    fprintf('Rotation angle: %.2f\n', rotAngle);

    % rotate image and landmarks and save to files
    rotImg = rotateToOrientation(img, rotAngle);
    imwrite(rotImg, strcat(rotDir, n, '.png'));
    rotPoints = rotatePointsToOrientation(img, points, rotAngle); 
    writePoints(rotPoints, strcat(rotDir, n, '.pts'));
end

function rotate_to_same_angle(Files, origDir)
   rotDir = 'FOREARM/Rotated/testing'; 
   for i = 1:size(Files,1)
        n = Files{i};
        rotate_one(n, 0, origDir, rotDir);
   end
end

% rotate into clusters every cs degrees (cs must be factor of 360)
function rotate_into_clusters(cs, Files, origDir)
   nrotated = 0;
   for deg = 0:cs:360-cs
       rotDir = sprintf('FOREARM/Rotated/testing/%d/',deg);
       dirSize = size(Files,1)/(360/cs);
       for i = (nrotated+1):(nrotated+dirSize)
            n = Files{i};
            rotate_one(n, deg, origDir, rotDir);
            nrotated = nrotated + 1;
       end
   end
end

% rotate a set of points which correspond to a rotated image
function rotPoints = rotatePointsToOrientation(img, points, alpha)
    rotPoints = zeros(size(points));
    sz = size(img) / 2;
    for i = 1:size(points,1)
        orig_x = points(i,1) - sz(2);
        orig_y = points(i,2) - sz(1);
        rot_mat=[cosd(alpha), sind(alpha); -sind(alpha) ,cosd(alpha)];
        old_orig = [orig_x orig_y];
        new_orig = old_orig * rot_mat;
        rotPoints(i,1) = new_orig(1) + sz(2);
        rotPoints(i,2) = new_orig(2) + sz(1);
    end
end

% write a set of points to a pts file
function writePoints(points, file)
    fid = fopen(file, 'wt'); % Open for writing
    fprintf(fid, 'version: 1\nn_points: %d\n{\n', size(points,1)); % write preamble
    for i=1:size(points,1)
       fprintf(fid, '%3.6f %3.6f\n', points(i,:));
    end
    fprintf(fid, '}');
    fclose(fid);
end

% rotate image to the specified angle
function rotated = rotateToOrientation(img, angle)
    % negative angle because imrotate rotates ANTICLOCKWISE
    rotated = imrotate(img, -angle, 'bilinear', 'crop');
    
    % uncomment to show rotated image
    %figure, imshow(rotated);
    %drawnow;
end

% Read point data from file into Nx2 array
function [points] = read_points(file)

    N = 37;
    points = zeros(N,2);
    
    % Open file
    fid = fopen(file, 'rt');
    if fid < 1,
       error([' Can not open file ', file]);   
    end

    % Skip preamble
    c = '';
    while ~strcmp(c,'{'),
        c = fscanf(fid, '%c', 1);
    end
    
    for i = 1:N
        points(i,:) = fscanf(fid, '%f', 2);
    end

    % Close file
    fclose(fid);
end

% returns angle required to rotate the line from centre to endpoint to the goal orientation
% (CLOCKWISE)
function alpha = rotationAngle(goal, centre, endpoint)
  x1 = centre(1);
  y1 = centre(2);
  x2 = endpoint(1);
  y2 = endpoint(2);
  dx = abs(x2 - x1);
  dy = abs(y2 - y1);
  
  if (y1 < y2)
      theta = atand(dy/dx);
      if (x1 < x2)
          alpha = 360 - theta - (90 + goal);
      else
          alpha = 90 + theta - goal;
      end
  else
      theta = atand(dx/dy);
      if (x1 < x2)
          alpha = 360 - theta - goal;
      else
          alpha = theta - goal;
      end
  end
end