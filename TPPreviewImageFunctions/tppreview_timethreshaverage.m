function [ims,channels] = tppreview_timethreshaverage(dirnames, tpparams, channellist, parameters, shortname, dirname)
% TPPREVIEW_TIMETHRESHAVERAGE - Make a preview image based on thresholded temporal differences
%
%  [IMS,CHANNELS] = TPPREVIEW_TIMETHRESHAVERAGE(DIRNAME,TPPARAMS,CHANNELLIST,PARAMETERS)
%
%  Inputs:
%    DIRNAME - The 2-photon directory to analyze (full path)
%    TPPARAMS - The parameter structure of the 2-photon directory
%    CHANNELLIST - A vector list of channels to include
%    PARAMETERS - Filter parameters structure with the following fields:
%       numFrames   -  Number of frames to average
%       smoothness  -  Number of pixels to smooth (1 is no smoothing)
%       diffTresh   -  The difference threshold; actual threshold applied is diffThresh / dT, where dT is time between frames
%       show_dFdT   -  Image should be dFdT rather than F (if this parameter is not provided, we will assume it is 1)

disp('calculating..');

channels = []; fnameparameters = {};

 % handle old case with no show_dFdT param

if ~isfield(parameters,'show_dFdT'),
	parameters.show_dFdT = 0;
end;

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
    	ims{i} = tp_preview_timethreshaverage_meat(dirnames,tpparams,{fnameparameters{i}},channel,parameters);
    end;
end;

function im_out = tp_preview_timethreshaverage_meat(dirnames,params,fnameparameters,channel,parameters)

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

n = 1:parameters.numFrames;

if parameters.numFrames > size(ffile,1),
	warning(['Requested averaging of ' int2str(parameters.numFrames) ...
		' frames is less than the number of frames in the recording (' int2str(size(ffile,1)) ') so using all available frames.']);
	parameters.numFrames = size(ffile,1);
end;

im = [];
for i=1:parameters.numFrames,
	imnew = tpreadframe(dirnames{1},fnameparameters{1},ffile(n(i),1),channel,ffile(n(i),2));
	im = cat(3,im,imnew);
end;

im = double(im);

if parameters.smoothness>1,
	for z=1:size(im,3),
		im(:,:,z) = medfilt2(im(:,:,z),round(parameters.smoothness)*[1 1]);
	end;
end;

imdiff = diff(im,1,3);
z = find(imdiff<parameters.diffThresh);

if parameters.show_dFdT,
	imdiff_z = imdiff;
	imdiff_z(z) = NaN;
	im_out = nanmean(imdiff_z,3);
else,
	z = z + size(im,1)*size(im,2); % advance indexes
	im(z) = NaN;
	im(:,:,1) = NaN;
	im_out = nanmean(im,3);
end;

%im_out = reshape(im_out,params{1}.Main.Lines_per_frame,params{1}.Main.Pixels_per_line);
