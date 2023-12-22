function b = suite2ptifs2prairieview(suite2p_exper_dir, new_exper_dir, directory_mapping, channel_mapping, doit)
% SUITE2PTIFS2PRAIRIEVIEW - convert a set of suite2p registrations back to PrairieView
%
% B = SUITE2PTIFS2PRAIRIEVIEW(SUITE2P_EXPER_DIR, NEW_EXPER_DIR, ...
%           DIRECTORY_MAPPING, CHANNELMAPPING, DO_IT)
%
% This function examines two-photon experiments that originated from PrairieView and
% were analyzed and registered with Suite2p, and converts the registered TIFFs back to
% PrairieView format, so they retain their metadata except for being registered.
%
% Inputs:
%   SUITE2P_EXPER_DIR - the directory name of the directory where Suite2p analysis has occurred.
%       This should be a high level directory, that has directories like 't0000X' in it; and inside
%       those folders should be a directory called Suite2p.
%
%  NEW_EXPER_DIR - this should be a directory, possibly blank but created, where the files will be
%       transferred to.
% 
%  DIRECTORY_MAPPING - a 2-d cell array of directory mappings between the SUITE2P_EXPER_DIR subdirectories
%       and the NEW_EXPER_DIR folder. The first entry of each cell array should correspond to a directory
%       in the SUITE2P_EXPER_DIR folder. The subsequent entries should be the list of NEW_EXPER_DIR 
%       directories that correspond.
%       For example:
%                   % specify a one-to-one mapping
%                 directory_mapping{1}{1} = 't00001-001';
%                 directory_mapping{1}{2} = {'t00001-001'};
%                   % specify a many-to-one mapping
%                 directory_mapping{1}{1} = 't00004-6-001';
%                 directory_mapping{1}{2} = {'t00004-001', 't00005-001', 't00006-001' };
%
%
% CHANNEL_MAPPING - a 2-d array of mapping between channels from Suite2p onto PrairieView
%       For example: 
%                   % specify that 2p channel 0 goes to PrairieView channel 2
%                  channel_mapping = [ 0 2 ]; 
%
% DO_IT - should we actually do it, or just say what we would do to check that everything is right?
%

if ~isfolder(new_exper_dir),
	error(['New folder needs to already exist: ' new_exper_dir ]);
end;

disp(['']);
disp(['']);

disp(['Beginning copy of Suite2p registration data to PrairieView ...'])

disp(['Source directory: ' suite2p_exper_dir ' ... ']);
disp(['Destination directory: ' new_exper_dir ' ... ']);

for i=1:size(directory_mapping,2),

	disp(['   Working on subdirectory ' int2str(i) ' of ' int2str(size(directory_mapping,2)) '.']);

	% Step 1: verify it has a Suite2p subdirectory

	S2pfolder = fullfile(suite2p_exper_dir,directory_mapping{i}{1},'suite2p');

	if ~isfolder(S2pfolder),
		error([S2pfolder ' does not exist.']);
	else,
	end;

	% Step 2: verify that targets exists on S2P side and does not exist on new side

	for j=1:numel(directory_mapping{i}{2}),
		Sp2target = fullfile(suite2p_exper_dir,directory_mapping{i}{2}{j});
		newtarget = fullfile(new_exper_dir,directory_mapping{i}{2}{j});

		if ~isfolder(Sp2target),
			error([Sp2target ' does not exist.']);
		end;

		if isfolder(newtarget),
			error([newtarget ' does exist. Will not overwrite.']);
		end;
		mkdir(newtarget)

		disp(['      Copying from ' Sp2target ' to ' newtarget '.']);

		copyPrairieViewData(Sp2target,newtarget,1,doit);
	end;

	% now copy images files from Suite2p to the set of directories

	disp(['      Now updating images with Suite2p-registered versions.']);

	copySuite2pdata2PrairieView(suite2p_exper_dir,directory_mapping{i}{1},new_exper_dir,...
		directory_mapping{i}{2},channel_mapping(1,1),channel_mapping(1,2),doit);
end;


