function [ims,channels] = tppreview_frameaverage(dirnames, tpparams, channellist, parameters)

channels = []; fnameparameters = {};

% lets find parameter files, get the file name prefix pattern

for j=1:length(channellist),
	good = 0;
	try,
		myfnameparameters=tpfnameparams(dirnames{1},channellist(j),tpparams{1});
		good = 1;
	end;
	if good,
		channels(j) = channellist(j);
		fnameparameters{j} = myfnameparameters;
	else,
		fnameparameters{j} = [];
	end;
end;

ims = {};

for i=1:length(channels),
	channel = channels(i);
    if ~isempty(fnameparameters{i}),
    	ims{i} = tp_preview_average_meat(dirnames,tpparams,{fnameparameters{i}},channel,parameters.firstFrames,parameters.numFrames);
    end;
end;

function im = tp_preview_average_meat(dirnames,params,fnameparameters,channel,firstFrames,numberFrames)

if isfield(params{1},'Type'),
	if strcmp(params{1}.Type,'Linescan')|strcmp(params{1}.Type,'linescan'),
		im = double(imread(fullfile(dirnames{1},tpfilename_linescansource(fnameparameters{1},1,channel))));
		im = medfilt2(im,[5 5]);
		return;
	end;
end;

% now read in which frames correspond to which file names (file names have a cycle number and cycle frame number)

ffile = repmat([0 0],length(params{1}.Image_TimeStamp__us_),1);
dr = [];
initind = 1;

for i=1:params{1}.Main.Total_cycles,
	numFrames = getfield(getfield(params{1},['Cycle_' int2str(i)]),'Number_of_images');
	ffile(initind:initind+numFrames-1,:) = [repmat(i,numFrames,1) (1:numFrames)'];
	initind = initind + numFrames;
end;
if exist([dirnames{1} filesep 'driftcorrect']),
	drfile = load([dirnames{1} filesep 'driftcorrect'],'-mat');
	dr = [dr; drfile.drift];
end;

if firstFrames,
	n = 1:numberFrames;
	else,
	        N = randperm(length(params{i}.Image_TimeStamp__us_));
		n = N(1:numberFrames);
	end;

if numberFrames > size(ffile,1),
	warning(['Requested averaging of ' int2str(numberFrames) ' frames is less than the number of frames in the recording (' int2str(size(ffile,1)) ') so using all available frames.']);
	numberFrames = size(ffile,1);
end;

im = [];
for i=1:numberFrames,
	imnew = tpreadframe(dirnames{1},fnameparameters{1},ffile(n(i),1),channel,ffile(n(i),2));
	if isempty(im),
		im = double(imnew)*1/numberFrames;
	else,
		im = im + double(im_new)*1/numberFrames;
	end
end;

%if size(im,3)>1, im = mean(double(im),3); else, im = double(im); end;
%im = reshape(im,params{1}.Main.Lines_per_frame,params{1}.Main.Pixels_per_line);
