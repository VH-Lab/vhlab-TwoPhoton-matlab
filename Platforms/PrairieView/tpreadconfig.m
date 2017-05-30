function params=tpreadconfig( tpdirname )
%TPREADCONFIG read twophoton experiment config file
% 
% PARAMS = TPREADCONFIG(TPDIRNAME)
%
% Reads the parameters from the 2-photon data directory
% TPDIRNAME. TPDIRNAME should be a full path to the 2-photon directory.
%
% Output:
%  PARAMS.Main.Total_cycles  (total number of cycles)
%  PARAMS.Main.Scanline_period__us_  (scanline period, in us)
%  PARAMS.Main.Dwell_time__us_  (pixel dwell time, in us)
%  PARAMS.Main.Frame_period__us_  (frame period, in us)
%  PARAMS.Main.Lines_per_frame (lines per frame)
%  PARAMS.Main.Pixels_per_line  (number of pixels per line)
%  PARAMS.Image_TimeStamp__us_  (list of all frame timestamps)
%  PARAMS.Cycle_N.Number_of_images (num. of images in Cycle N)
%
%   PARAMS.Image_TimeStamp__s_   = PARAMS.Image_TimeStamp__us_ * 1E-6
%
% This is the PrairieView version
% 
% written by Steve VanHooser, Mark Mazurek, Alexander Heimel
%

pcfile = dir([tpdirname filesep '*_Main.pcf']);
if isempty(pcfile)
	pcfile = dir([tpdirname filesep '*.xml']);
end;
if isempty(pcfile),
	error(['Could not find parameters in directory ' tpdirname '.']);
end;
pcfile = pcfile(end).name;
params = readprairieconfig([tpdirname filesep pcfile]);
 
params.Image_TimeStamp__s_   = params.Image_TimeStamp__us_ * 1e-6; %change to s
