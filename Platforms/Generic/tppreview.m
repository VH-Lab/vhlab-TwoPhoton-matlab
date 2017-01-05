function [im,params]= previewprairieview(dirname, numFrames, firstFrames, channel)

%  PREVIEWPRAIRIEVIEW - Preview PrairieView image data
%
%    IM = PREVIEWPRAIRIEVIEW(DIRNAME, NUMFRAMES, FIRSTFRAMES,CHANNEL)
%
%  Read a few frames to create a preview image.  DIRNAME is the
%  directory name to be opened, and NUMFRAMES is the number of
%  frames to read.  If FIRSTFRAMES is 1, then the first NUMFRAMES
%  frames will be read; otherwise, the frames will be taken
%  randomly from those available.
% 
%  CHANNEL is the channel to be read.  If it is empty, then
%  all channels will be read and third dimension of im will
%  correspond to channel.  For example, im(:,:,1) would be
%  preview image from channel 1.
%
%  DIRNAME will have '-001' appended to it.
%

tpdirname = [dirname];

if ~exist(tpdirname),
	error(['Directory ' tpdirname ' does not exist.']);
end;

params = tpreadconfig([tpdirname]);
tpfileparams = tpfnameparams(tpdirname,channel,params);

if firstFrames,
	n = 1:numFrames;
else,
	N = randperm(length(params.Image_TimeStamp__us_));
	n = N(1:numFrames);
end;

im = [];
for i=1:numFrames,
    fname = tpfilename(tpfileparams,1,channel,i),
    fnamefull = fullfile(tpdirname,fname),
    im = cat(3,im,imread(fnamefull));
end;
if size(im,3)>1, im = mean(double(im),3); else, im = double(im); end;
im = reshape(im,params.Main.Lines_per_frame,params.Main.Pixels_per_line);
