function copySuite2pdata2PrairieView(suite2p_exper_dir, suite2p_source_dir, new_exper_dir, prairie_target_dir_list, channel_in, channel_out, doit);

if nargin<7,
	doit = 0;
end;

disp(['Working on Suite2p directory ' suite2p_source_dir '...']);

 % Step 1: count the number of suite2p frames

suite2pdir = fullfile(suite2p_exper_dir,suite2p_source_dir,'suite2p','plane0','reg_tif');

suite2ptiffs = dir([suite2pdir filesep '*chan' int2str(channel_in) '.tif']);

suite2p_frames_per_tiff = [];

finfo = {};

for i=1:numel(suite2ptiffs),
	finfo{i} = imfinfo(fullfile(suite2pdir,suite2ptiffs(i).name));
	suite2p_frames_per_tiff(i) = numel(finfo{i});
end;

disp(['Found ' mat2str(suite2p_frames_per_tiff) ' frames in ' ...
	int2str(numel(suite2p_frames_per_tiff)) ' TIF files.'])

 % Step 2: produce a list of filenames for prairieview frames

prairieviewfilenames = {};

for i=1:numel(prairie_target_dir_list),
	prairie_tiffs_here = dir(fullfile(new_exper_dir,prairie_target_dir_list{i},...
		['*Ch' int2str(channel_out) '*.tif']));
	prairie_tiffs_here = sort({prairie_tiffs_here.name}); % make sure alphanumerical
	for j=1:numel(prairie_tiffs_here),
		prairie_tiffs_here{j} = [fullfile(new_exper_dir,prairie_target_dir_list{i},...
			prairie_tiffs_here{j})];
	end;
	prairieviewfilenames = cat(2,prairieviewfilenames,prairie_tiffs_here);
end;

if sum(suite2p_frames_per_tiff) ~= numel(prairieviewfilenames),
	if doit, 
        error(['Number of suite2p frames ( ' int2str( suite2p_frames_per_tiff ) ') ' ...
		'does not match PrairieView frames (' int2str(numel(prairieviewfilenames)) ').']);
    end;
else,
	disp('PrairieView frame numbers match Suite2p frame numbers');
end;

disp(['Copying ' int2str(sum(suite2p_frames_per_tiff)) ' images...']);

count = 1;

for i=1:numel(suite2p_frames_per_tiff),

	tf_in = Tiff(fullfile(suite2pdir,suite2ptiffs(i).name));
	tagnames = {'ImageWidth','ImageLength','Photometric','BitsPerSample','Compression',...
		'PlanarConfiguration','XResolution','YResolution','SampleFormat'};
	tagvalues = {};
	for k=1:numel(tagnames),
		tagvalues{k} = tf_in.getTag(tagnames{k});
	end;


	for j=1:suite2p_frames_per_tiff(i),
		im = imread(fullfile(suite2pdir,suite2ptiffs(i).name),...
			'info',finfo{i},'index',j);
		if doit,
			tf = Tiff(prairieviewfilenames{count},'w');
			for k=1:numel(tagnames),
				tf.setTag(tagnames{k},tagvalues{k});
			end;
			tf.setTag('ImageLength',size(im,1));
			tf.setTag('ImageWidth',size(im,2));
			tf.setTag('BitsPerSample',16);
			tf.setTag('Software','Suite2p');
			tf.write(im);
			tf.close();
		end;
		count = count + 1;
	end;
end;
