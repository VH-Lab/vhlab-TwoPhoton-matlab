function [pvimg, params, total_frames] = TPPreviewImageFunctionListGetPreviewImageParams(dirname, shortname, channel, frame)
% TPPREVIEWIMAGEFUNCTIONLISTGETPREVIEWIMAGEPARAMS - Get preview image and parameters
%
%   [PVIMG,PVPARAMS,TOTAL_FRAMES] = TPPREVIEWIMAGEFUNCTIONLISTGETPREVIEWIMAGEPARAMS(DIRNAME, ...
%       SHORTNAME, CHANNEL, FRAME)
%
%   Loads (and computes if necessary) the preview image and preview parameters associated
%   with DIRNAME and TPPreviewImageFunctionList element with the given SHORTNAME for imaging
%   channel CHANNEL and image frame number FRAME.  If FRAME is not provided, it is assumed
%   to be frame 0, which corresponds to the preview image.
%
%   PVIMG is an image of the preview image, pvparams are the twophoton imaging parameters,
%   and TOTAL_FRAMES is the total number of frames available in the directory.
%
%   The function returns an error if no TPPreviewImageFunctionList entry with SHORTNAME
%   exists.
%


 % sdv 2017-01-24

if nargin<4,
	frame = 0;
end;

verbose = 0;

frame = round(frame); % make sure it is an integer

TPPreviewImageFunctionListGlobals;

[static_filename, video_filename] = TPPreviewImageFunctionGetFilename(dirname, shortname, channel, frame);

parentdir = fileparts(dirname);

goodload = 0;
if exist(static_filename,'file'),
	out = TPPreviewImageFunctionListGetCache([static_filename]);
	if frame~=0,
		params = out.params;
		total_frames = length(params{1}.Image_TimeStamp__us_);
		try,
			dirnames = out.dirnames;
			tpfnameparameters = out.tpfnameparameters;
			videoinfo = out.videoinfo;
			if ~exist('tpfnameparameters','var') | ~exist('dirnames','var'), error(['variables we needed were not found.']); end;
			if ~exist('videoinfo','var'), error(['variables we needed were not found.']); end;
		catch,
			if verbose, disp(['recomputing tpfnameparameters and dirnames']); end;

			dirnames = tpdirnames(dirname);
			tpparams = {};
			tpfnameparameters = {};

			if isa(dirnames,'cell'),
				for i=1:length(dirnames),
					tpparams{i} = tpreadconfig(dirnames{i});
					tpfnameparameters{i} = tpfnameparams(dirnames{i},channel,tpparams{i});
				end;
	       		else,
				tpparams = tpreadconfig(dirnames);
				tpfnameparameters{1} = tpfnameparams(dirnames,channel,tpparams);
			end;
			if exist(video_filename,'file'),
				videoinfo = imfinfo(video_filename);
			else,
				videoinfo = [];
			end;
			save([static_filename],'tpfnameparameters','dirnames','videoinfo','-append','-mat');
			TPPreviewImageFunctionListAddCache(static_filename, out.pvimg, out.params, out.parameters, out.dirname, ...
				tpfnameparameters,total_frames,dirnames,videoinfo);
		end;

		if ~exist(video_filename,'file'),
			if verbose, disp('no video file but want frames'); end;
			ffile = repmat([0 0],length(params{1}.Image_TimeStamp__us_),1);
			initind = 1;

			for i=1:params{1}.Main.Total_cycles,
				numFrames = getfield(getfield(params{1},['Cycle_' int2str(i)]),'Number_of_images');
				ffile(initind:initind+numFrames-1,:) = [repmat(i,numFrames,1) (1:numFrames)'];
				initind = initind + numFrames;
			end;
			% params already loaded above

			% chuck the loaded parent path, it might be bogus
			for i=1:numel(dirnames),
				% cannot call fileparts because cache might be from different platform
				delimiters = find(dirnames{i} == '/' | dirnames{i} == '\'); 
				if isempty(delimiters),
					delimeters = 0; % there is no path pre-pended
				end;
				dirnamehere = dirnames{i}(delimiters(end)+1:end);
				dirnames{i} = [parentdir filesep dirnamehere];
			end
			pvimg = tpreadframe(dirnames{1},tpfnameparameters{1},ffile(frame,1),channel,ffile(frame,2));
			return;
		else,
			pvimg = imread(video_filename, frame, 'info', videoinfo);
			return;
		end;
	else,
		pvimg = out.pvimg;
		params= out.params;
		parameters = out.parameters;
		total_frames = length(params{1}.Image_TimeStamp__us_);

		gotmatch = 0;
		for i=1:length(TPPreviewImageFunctionList),
			if strcmp(TPPreviewImageFunctionList(i).shortname,shortname),
				gotmatch = eqlen(parameters,TPPreviewImageFunctionList(i).parameters);
			end;
		end;
		goodload = gotmatch;
	end;
end;

if verbose,	
	disp(['file exists is ' int2str(exist(static_filename,'file')) ]); 
	disp(['Goodload is ' int2str(goodload) '.']);
end;

if ~goodload,	% not present or old parameters so must compute or re-compute

	dirnames = tpdirnames(dirname);
	tpparams = {};
	tpfnameparameters = {};

	if isa(dirnames,'cell'),
		for i=1:length(dirnames),
			tpparams{i} = tpreadconfig(dirnames{i});
			tpfnameparameters{i} = tpfnameparams(dirnames{i},channel,tpparams{i});
		end;
	else,
		tpparams = tpreadconfig(dirnames);
		tpfnameparameters{1} = tpfnameparams(dirnames,channel,tpparams);
	end;
	total_frames = length(tpparams{1}.Image_TimeStamp__us_);

	match = 0;
	for i=1:length(TPPreviewImageFunctionList),
		if strcmp(TPPreviewImageFunctionList(i).shortname,shortname),
			match = 1;
			eval(['[ims,thechannel] = ' TPPreviewImageFunctionList(i).FunctionName  ...
				'(dirnames,tpparams,channel,TPPreviewImageFunctionList(i).parameters, TPPreviewImageFunctionList(i).shortname,dirname);']);
			for j=1:length(thechannel),
				pvimg = ims{j};
				params=tpparams;
				parameters = TPPreviewImageFunctionList(i).parameters;
				[static_filename_, video_filename_] = TPPreviewImageFunctionGetFilename(dirname, shortname, thechannel(j), frame);
				if exist(video_filename_),
					videoinfo = imfinfo(video_filename_);
				else,
					videoinfo = [];
				end;
				save(static_filename_, 'pvimg','params','parameters','dirname','tpfnameparameters',...
					'total_frames','dirnames','videoinfo','-mat');
				TPPreviewImageFunctionListAddCache(static_filename_,pvimg,params,parameters,...
					dirname,tpfnameparameters,total_frames,dirnames,videoinfo);
			end;
		end;
	end;
	if match==0,
		error(['Could not find TPPreviewImageFunctionList item with shortname equal to ' shortname '.']);
	end;
	% otherwise, pvimg and params should exist 

	if frame~=0, % need to replace pvimg with the frame data
		errordlg(['Steve did not think this could occur. Let him know.']);
	end;
end;

