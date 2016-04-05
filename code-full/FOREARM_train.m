function FOREARM_train(N, mix, sbin)
% Train a forearm model with N parts and mix mixtures per part
% sbin = Spatial resolution of HOG cell in terms of pixel width and height
	globals;
	name = 'FOREARM_ROT';
	N
	mix
	sbin
    [K, pa] = get_K_pa(N,mix);

	% --------------------
	% Prepare training and testing images and part bounding boxes
	% You will need to write custom *_data() functions for your own dataset
	suffix = [num2str(mix) '_' num2str(N)];
    [pos, neg, test] = FOREARM_data(name, suffix, mix);
	pos = point2box(pos,pa);
	% --------------------
	% training
	model = trainmodel(name,pos,neg,K,pa,sbin);
end
