function im = tppreview(dirname, numFrames, firstFrames, channel)
%  TPPREVIEW - Preview twophoton image data
%
%    IM = TPPREVIEW(DIRNAME, NUMFRAMES, FIRSTFRAMES,CHANNEL)
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
%  2008, shell around PREVIEWPRAIRIEVIEW
%

if channel>1, warning('tppreview for Leica does not yet work with multiple channels'); end;

if ~exist(dirname,'dir'),
	error(['Directory ' dirname ' does not exist.']);
end;

params = tpreadconfig(dirname);


total_nFrames=length(params.Image_TimeStamp__s_); % probably not correct with multiple channels

if firstFrames,
	frame_selection = 1:numFrames;
else
	N = randperm(total_nFrames);
	frame_selection = N(1:numFrames);
end;

fnameprefix = tpfnameprefix(dirname,channel);

im = double(tpreadframe(dirname,fnameprefix,1,channel,frame_selection(1)));

for f=frame_selection(2:end)
  im = im+double(tpreadframe(dirname,fnameprefix,1,channel,f));
end;

im=double(im)/numFrames;

