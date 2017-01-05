function params=tpreadconfig( tpdirname )
%TPREADCONFIG read twophoton experiment config file
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
%   params.Image_TimeStamp__s_   = params.Image_TimeStamp__us_ * 1E-6
%
% Generic version, just makes up these numbers for a directory of 
%  TIFF files
% 
% Steve VanHooser, Alexander Heimel
%

d = dir([tpdirname filesep '*.tif*']);

im = imread([tpdirname filesep d(1).name]);

% say each image takes 1 second to record, arbitrarily

params.Main.Total_cycles = 1;
params.Main.Scanline_period__us_ = 1/size(im,2); % total guess here as to dimension
params.Main.Frame_period__us_ = 1e6;
params.Main.Lines_per_frame = size(im,2); % total guess here as to dimension
params.Main.Pixels_per_line = size(im,1);
params.Main.Dwell_time__us_ = params.Main.Scanline_period__us_ / size(im,1);
params.Image_TimeStamp__us_ = ((1:length(d))-1) * 1e6;
params.Cycle_1.Number_of_images = length(d);
 
params.Image_TimeStamp__s_   = params.Image_TimeStamp__us_ * 1e-6; %change to s
