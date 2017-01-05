function params=tpreadconfig( tpdirname )
%TPREADCONFIG read twophoton/confocal experiment config file
%
%
% PARAMS. = 
%  params.Main.Total_cycles  (total number of cycles)
%  params.Main.Scanline_period__us_  (scanline period, in us)
%  params.Main.Dwell_time__us_  (pixel dwell time, in us)
%  params.Main.Frame_period__us_  (frame period, in us)
%  params.Main.Lines_per_frame (lines per frame)
%  params.Main.Pixels_per_line  (number of pixels per line)
%  params.Image_TimeStamp__us_  (list of all frame timestamps)
%  params.Cycle_N.Number_of_images (num. of images in Cycle N)
%
%  params.Image_TimeStamp__s_   = params.Image_TimeStamp__us_ * 1E-6
%
% 
% Steve Van Hooser, Alexander Heimel
%

d = dir([tpdirname filesep '*.tif*']);

if isempty([d]),
	error(['No TIF file in directory ' tpdirname '.']);
end;

fileinfo = imfinfo([tpdirname filesep d(1).name]);

config_str = char(fileinfo(1).UnknownTags(2).Value);
config_str = config_str(14:2:end); 
if size(config_str,1)>size(config_str,2), config_str = config_str'; end; % make sure we are many columns, one row

% say each image takes 1 second to record, arbitrarily

params.Main.Total_cycles = 1; % only 1 cycle
params.Main.Scanline_period__us_ = 1e-4; % scan is "instant"
params.Main.Frame_period__us_ = 1e-2;    % scan is "instant"
params.Main.Lines_per_frame = fileinfo(1).Height; 
params.Main.Pixels_per_line = fileinfo(1).Width;
params.Main.Dwell_time__us_ = 1e-6; % scan is instant

[imagetimes,imagestart] = GetFrameTimes(config_str);

params.Image_TimeStamp__us_ = 1e6*imagetimes;
params.Cycle_1.Number_of_images = length(fileinfo);
params.ImageStart = imagestart;

params.Image_TimeStamp__s_   = imagetimes;


function [imagetimes, imagestart] = GetFrameTimes(config_str)
 % imagetimes - offsets in us from the first recording;
 % imagestart - time vector of the first sample

imagetimes = [];

k1 = strfind(config_str,'<TimeStamp>');
k2 = strfind(config_str,'</TimeStamp>');

if length(k1)~=length(k2),
	error(['Number of <TimeStamp> openings must match </TimeStamp> closings.']);
end;

L = length('<TimeStamp>');

for i=1:length(k1),
	V = fulltimestamp2datevec(config_str(k1(i)+L:k2(i)-1));
	if i==1,
		imagestart = V;
		imagetimes(i) = 0;
	else,
		imagetimes(i) = datevecdiff(imagestart,V);
	end;
end;


