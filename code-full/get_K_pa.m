function [K, pa] = get_K_pa(N, mix)
% Define tree structure for N parts: pa(i) is the parent of part i
% K = number of mixtures per part

    K = repmat(mix,1,N); % define "mix" mixtures for all N parts

    % 29 PART MODEL
    if (N == 29)
        % i = 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
        pa = [0 1 2 3 4 5 6 7 8 9 10 10 12 13 14 15 1  17 18 19 20 21 22 23 24 25 ...
              26 27 28];
        % i =  27 28 29
    elseif (N == 14)
        % Cut down tree structure with 14 parts:
        %i =  1 2 3 4 5 6 7 8 9 10 11 12 13 14
        pa = [0 1 2 3 4 5 6 7 1 9 10 11 12 13];

    % 37 PART MODEL
    elseif (N == 37)
        % i =  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
        pa = [0 1 2 3 4 5 6 7 8 9  10 1  12 13 14 15 16 17 18 19 20 21 22 1  24 25 ...
               26 27 28 29 30 31 32 33 34 35 36];
        % i =  27 28 29 30 31 32 33 34 35 36 37
    elseif (N == 18)
        %Cut down tree with 18 parts:
        %i =  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
        pa = [0 1 2 3 4 1 6 7 8 9  10 1 12  13 14 15 16 17];
    elseif (N == 11)
        % 11 part skeletal model
        pa = [0 1 2 3 4 5 6 7 8 9  10];
    end
end