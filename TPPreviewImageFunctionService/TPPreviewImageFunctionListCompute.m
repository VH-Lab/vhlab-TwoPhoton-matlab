function TPPreviewImageFunctionListCompute(dirname)

% TPPREVIEWIMAGEFUNCTIONLISTCOMPUTE - Compute preview images for a directory
%
%   TPPREVIEWIMAGEFUNCTIONLISTCOMPUTE(DIRNAME)
%
%   runs all TPPREVIEWIMAGEFUNCTIONs in the list on the 2-photon data associated with the directory
%   DIRNAME and saves the results to the directory DIRNAME in .mat files.

TPPreviewImageFunctionListGlobals;

if length(TPPreviewImageFunctionList)==0,
	warning(['No TPPreviewImageFunctions installed...will not compute preview images']);
	return;
end; % no preview function

dirnames = tpdirnames(dirname);

if isa(dirnames,'cell'),
	for i=1:length(dirnames),
		tpparams{i} = tpreadconfig(dirnames{i});
	end;
else,
	tpparams = tpreadconfig(dirnames);
end;


for i=1:length(TPPreviewImageFunctionList),
	channellist = [];
	for j=1:length(TPPreviewImageFunctionChannelList),
		goodload = 0;
		channelhere = TPPreviewImageFunctionChannelList(j);
		% check to see if all channels have been processed properly and with current parameters
		filename = [dirname filesep 'tppreview_' TPPreviewImageFunctionList(i).shortname '_ch' int2str(channelhere) '.mat'];
		if exist(filename)==2,
			z = load(filename);
			goodload = eqlen(z.parameters,TPPreviewImageFunctionList(i).parameters);
		end;
		if ~goodload,
			channellist(end+1) = channelhere;
		end;
	end;
	if ~isempty(channellist),
		eval(['[ims,channels] = ' TPPreviewImageFunctionList(i).FunctionName  ...
			'(dirnames,tpparams,channellist,TPPreviewImageFunctionList(i).parameters);']);
	else,
		ims = [];
	end;
	if ~isempty(ims),  % make sure something successful was returned
		for j=1:length(channels),
			pvimg = ims{i};
			params=tpparams;
			parameters = TPPreviewImageFunctionList(i).parameters;
			shortname = TPPreviewImageFunctionList(i).shortname;
			save([ dirname filesep 'tppreview_' shortname '_ch' int2str(channels(j)) '.mat'],'pvimg','params','parameters','-mat');
		end;
	end;
end;

