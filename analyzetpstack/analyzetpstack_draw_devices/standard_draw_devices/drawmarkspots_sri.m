function celllist = drawmarkspots_sri(parameters, inputs)

% DRAWMARKSPOTS_SRI - Import a cell list from drawing of centroids.
%
%   CELLLIST = DRAWMARKSPOTS_SRI(PARAMETERS, INPUTS)
%
%     PARAMETERS should be a structure with the following entries:
%         min_area        Minimum area for a spot to be considered a cell
%         channel_order   Order in which channels should be processed
%         overlap         How much of a neighboring channel should be labeled in order to be considered double labeled?
%         labels1         Labels for channel 1
%         labels2         Labels for channel 2
%         labels3         Labels for channel 3
%         labels4         Labels for channel 4
%         chan1method     How to obtain data for channel1?
%         chan2method     How to obtain data for channel2?
%         chan3method     How to obtain data for channel3?
%         chan4method     How to obtain data for channel4?
%
%
%     INPUTS is the standard ANALYZETPSTACK_DRAW_DEVICE input structure with fields
%         previewim                 The current directory's preview image
%                                               (the NxM pixel image)
%         fullpathdirname           The full path of the directory being examined
%         dirname                   The dirname being examined
%         drift                     The calculated "shift" between this image and the 
%                                       first image in the sequence of images that
%                                       were collected at this location (note that
%                                       this may be a shift onto a previous
%                                       recording if 2 or more recordings were made at
%                                       the same location).
%         ds                        A directory structure object for traversing the
%                                       file structure for the entire experiment.
%         default_type_string       The type string that is currently selected
%         default_label_strings     A cell list of the currently selected label strings
%         cell_index_counter        The current value of the cell index counter.
%
%      CELLLIST is a structure list of cell information as described in 
%          ANALYZETPSTACK_EMTPYCELLREC
%
%      The detection part of this procedure was written by Sri Raghavachari 2011

celllist = [];

if nargin==0,
	prompt = {'What is the minimum area for a cell, in square pixels?',...
		'In what order should the channels be processed?',...
		'How much should 2 ROIs overlap to be considered double-labeled (0-100)?',...
			'Label string for channel 1',...
			'Label string for channel 2',...
			'Label string for channel 3',...
			'Label string for channel 4',...
			'How get data for chan1? (0=preview,1=ask user):',...
			'How get data for chan2? (0=preview,1=ask user):',...
			'How get data for chan3? (0=preview,1=ask user):',...
			'How get data for chan4? (0=preview,1=ask user):',...
		};
	name = 'Parameters for the drawmarkspots_sri function';
	numlines = 1;
	defaultanswer = {'30','[1 2 3 4]','50','Oregon green', 'tdTomato','GFP','FURA','0','0','0','0'};
	answer = inputdlg(prompt,name,numlines,defaultanswer);
	if ~isempty(answer),
		p = struct('min_area',str2num(answer{1}),'channel_order',str2num(answer{2}),...
			'overlap',str2num(answer{3}),'labels1',answer{4},'labels2',answer{5},...
			'labels3',answer{6},'labels4',answer{7},'chan1method',str2num(answer{8}),'chan2method',str2num(answer{9}),'chan3method',str2num(answer{10}),'chan4method',str2num(answer{11}));
		celllist = p;
	end;
	return;
end;

nameref = getnamerefs(inputs.ds,inputs.dirname);

tests = gettests(inputs.ds,nameref(1).name,nameref(1).ref);

Res = {}; Mask = {}; LabeledMask = {}; Contours = {};

for i=1:length(parameters.channel_order),
	chanmethod = eval(['parameters.chan' int2str(parameters.channel_order(i)) 'method;']),
	labels = eval(['parameters.labels' int2str(parameters.channel_order(i))]);
	if chanmethod==0,
		disp(['Calculating preview image channel ' int2str(parameters.channel_order(1)) '.']);
		cellimage{i}=tppreview([fixpath(getpathname(inputs.ds)) filesep inputs.dirname],30,1,parameters.channel_order(i));
	elseif chanmethod==1,
		[filename, pathname, filterindex]=uigetfile({'*.tiff;*.tif','TIFF images'; '*.*', 'All files'},...
			['Pick an image file for label ' labels]);
		cellimage{i}=double(imread(fullfile(pathname,filename)));
    else, error(['Unknown chanmethod ' int2str(chanmethod) '.']);
	end;
	if ~isempty(cellimage{i}),
		[Res{i},Mask{i}] = spotDetector(cellimage{i});
		LabeledMask{i} = bwlabel(Mask{i},4);
		Contours{i} = bwboundaries(Mask{i},4);
		[LabeledMask{i},goodinds] = removesmallspots(LabeledMask{i},parameters.min_area);
		Contours{i} = Contours{i}(goodinds);
	else, error(['No image data for channel ' int2str(parameters.channel_order(i)) '.']);
	end;
end;

celllist = [];

for i=1:length(parameters.channel_order),
	labels = eval(['parameters.labels' int2str(parameters.channel_order(i))]);
	newcells = spots2celllist(LabeledMask{i}, inputs.dirname, inputs.cell_index_counter, labels,...
			inputs.default_type_string, Contours{i});
	inputs.cell_index_counter = inputs.cell_index_counter + length(newcells);
	for j=i+1:length(parameters.channel_order),
		% examine for double-labeling
		jlabel = eval(['parameters.labels' int2str(parameters.channel_order(j))]);
		[overlap_raw,overlap_norm,labelnum] = maskoverlap(LabeledMask{i},LabeledMask{j});
		for k=1:length(newcells), % are cells double-labeled?
			if overlap_norm(k)>=parameters.overlap/100, 
				newcells(k).labels{end+1} = jlabel;
			end;
		end;

		% remove these cells from other channels
		for k=1:length(newcells), % remove these locations
			LabeledMask{j}(newcells(k).pixelinds) = 0;
		end;
		% recalculate
		LabeledMask{j} = bwlabel((LabeledMask{j}>0),4);
		Contours{j} = bwboundaries((LabeledMask{j}>0),4);
		[LabeledMask{j},goodinds] = removesmallspots(LabeledMask{j},parameters.min_area);
		Contours{j} = Contours{j}(goodinds);
	end;
	if isempty(celllist), celllist = newcells; else, celllist = [celllist newcells]; end;
end;

