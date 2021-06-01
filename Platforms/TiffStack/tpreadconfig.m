function params=tpreadconfig( tpdirname )
%TPREADCONFIG read twophoton experiment config file - TiffStack 
%
% PARAMS = TPREADCONFIG(TPDIRNAME)
%
% Reads parameters for a generic TiffStack directory.
% 
% There must be a text file with the extension .tiffstack
% This file should contain the following lines:
% parameter<tab>value<tab>desc<tab>
% FrameRate<tab>VALUE<tab>The frame rate in Hz
% 
% The directory will be examined for a stack of TIFFS. If one is
% found, then the image size will be determined from this file. If
% multiple TIFF files are found, then it is assumed that they
% are sequential in alphabetical order, and that the last frame
% in one file occurs one frame before the first frame in the next file.
%
% The following parameters will be generated. For the purposes of
% importing generic TIFF stacks, it will be assumed
% that the scan happens very quickly (less than 1ms).
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
%  params.Image_TimeStamp__s_   = params.Image_TimeStamp__us_ * 1E-6
%
% 2016-7, SDV
%


pcfile = dir([tpdirname filesep '*.tiffstack']);

if isempty(pcfile),
	error(['No header file *.tiffstack in directory ' tpdirname '.']);
elseif length(pcfile)>1,
	error(['Multiple header files *.tiffstack in directory ' tpdirname '. Do not know what to do.']);
end;

extensionlist = {'.tif','.TIF','.TIFF','.tiff'};

foundit = 0;
for i=1:length(extensionlist),
	datafile = dir([tpdirname filesep '*' extensionlist{i} ]);
    % ignore any hidden files
    included = [];
    for jj=1:numel(datafile), 
        if datafile(jj).name(1)~='.',
            included(end+1) = jj;
        end;
    end;
    datafile = datafile(included);
	if isempty(datafile),
		%error(['No data file *.tif in directory ' tpdirname '.']);
	elseif length(datafile)>1,
		foundit = 1;
		break;
		%error(['Multiple data files *.' extensionlist{i} ' in directory ' tpdirname '. Do not know what to do.']);
	else,
		foundit = 1;
		break;
	end;
end;

if ~foundit,
	error(['No data file *.tif, *.tiff, *.TIF, *.TIFF in directory ' tpdirname '.']);
end;

tiffstackparamsdata = loadStructArray([tpdirname filesep pcfile(1).name]);

tiffstackparams = struct('dummy',0);

for i=1:length(tiffstackparamsdata),
	tiffstackparams = setfield(tiffstackparams,tiffstackparamsdata(i).parameter,tiffstackparamsdata(i).value);
end;

tiffstackparams = rmfield(tiffstackparams,'dummy');

   % we assume the TIF files in the directory all have the same parameters
theimfinfo = imfinfo([tpdirname filesep datafile(1).name]);

params.Main.Total_cycles = length(datafile);
params.Main.Scanline_period__us_ = 1;
params.Main.Dwell_time__us_ = params.Main.Scanline_period__us_ / theimfinfo(1).Width;
params.Main.Lines_per_frame = theimfinfo(1).Height;
params.Main.Pixels_per_line = theimfinfo(1).Width;
params.Main.Frame_period__us_ = 1e6 * (1/(tiffstackparams.FrameRate));

framecount = 0;
for i=1:params.Main.Total_cycles,
	cyclename = ['Cycle_' int2str(i)];
	theimfinfo = imfinfo([tpdirname filesep datafile(i).name]);
	num_of_images = length(theimfinfo);
	params = setfield(params,cyclename,...
		struct('Number_of_images', num_of_images, ...
			'filename', datafile(i).name, ...
			'imfinfo',theimfinfo));
	framecount = framecount + num_of_images;

end;

params.Main.Image_TimeStamp__us_ = (0:(framecount-1)) * params.Main.Frame_period__us_;

params.Image_TimeStamp__us_ = params.Main.Image_TimeStamp__us_;
params.Image_TimeStamp__s_ = params.Main.Image_TimeStamp__us_ * 1E-6;


