function params=tpreadconfig( tpdirname )
%TPREADCONFIG read twophoton experiment config file - Inscopix
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
% Inscopix version
%
% 2016, SDV
%


pcfile = dir([tpdirname filesep '*.xml']);

if isempty(pcfile),
	error(['No Inscopix .xml file in directory ' tpdirname '.']);
elseif length(pcfile)>1,
	error(['Multiple Inscopix .xml file in directory ' tpdirname '. Do not know what to do.']);
end;

xml = parseXML([tpdirname filesep pcfile(1).name]);
xml = xmlstruct_stripwhitespace(xml);
Inscopix_node = xmlstruct_findnode(xml,'attrs');
params.Inscopix = xmlstruct_attributename2struct(Inscopix_node.Children);

file_node = xmlstruct_findnode(xml,'file');
params.Inscopix.filename = file_node(1).Children(1).Data;
[dummy,params.Inscopix.filenameprefix,ext] = fileparts(file_node(1).Children(1).Data);

decompressed_node = xmlstruct_findnode(xml,'decompressed');

params.Main.Total_cycles = length(decompressed_node.Children);
framelist = [];
for i=1:params.Main.Total_cycles,
	cyclename = ['Cycle_' int2str(i)];
	num_of_images = eval(decompressed_node.Children(i).Attributes.Value);
	datafilename = decompressed_node.Children(i).Children(1).Data;
	theimfinfo = imfinfo([tpdirname filesep datafilename]);
	params = setfield(params,cyclename,...
		struct('Number_of_images', num_of_images, ...
			'filename', datafilename, ...
			'imfinfo',theimfinfo));

end;

params.Main.Scanline_period__us_  = 0;
params.Main.Dwell_time__us_ = 0; 
params.Main.Frame_period__us_ = 1e-6 * (1/(params.Inscopix.fps));
params.Main.Lines_per_frame = params.Inscopix.height;
params.Main.Pixels_per_line = params.Inscopix.width;
params.Main.Image_TimeStamp__us_ = (0:params.Inscopix.frames-1) * params.Main.Frame_period__us_;

params.Image_TimeStamp__us_ = params.Main.Image_TimeStamp__us_;
params.Image_TimeStamp__s_ = params.Main.Image_TimeStamp__us_ * 1E6;


if ~isempty(params.Inscopix.dropped)
	error(['Hey! We found a case with dropped frames. we should study it to see what to do to handle it gracefully.']);
end;


