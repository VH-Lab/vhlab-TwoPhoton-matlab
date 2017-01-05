function celllist = draw_adaptivethreshold(parameters, inputs)

% DRAW_ADAPTIVETHRESHOLD- Import a cell list from drawing of centroids.
%
%   CELLLIST = DRAW_ADAPTIVETHRESHOLD(PARAMETERS, INPUTS)
%
%     PARAMETERS should be a structure with the following entries:
%         localwindowsize Local window size [x y]
%	  paramC          parameterC for adaptivethreshold.m function
%         meanormedian    0/1 (mean/median for adaptivethreshold)
%         flare           pixels that each ROI should be "flared", that is, extended
%         min_area        Minimum area for a spot to be considered a cell
%         max_eccen       Maximum eccentricity for a spot to be considered a cell
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
%      

celllist = [];

if nargin==0,
	prompt = { 'What is local window size (e.g., [20 20])?', ...
		'What is parameter C (e.g., -0.05)?', ...
		'Use mean (0) or median (1) for adaptive threshold?', ...
		'How many points should we flare?', ...
                'What is the minimum area for a cell, in square pixels?',...
                'What is the maximum eccentricity allowed a cell from 0 - 1?',...
                'What is the minimum circularity allowed a cell from 0 - 1?',...
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
	defaultanswer = {'[20 20]', '-0.05', '0', '0', '120','2','0.4','[1 2 3 4]','50','Oregon green', 'tdTomato','GFP','FURA','0','0','0','0'};
	answer = inputdlg(prompt,name,numlines,defaultanswer);
	if ~isempty(answer),
		p = struct('localwindowsize',str2num(answer{1}), 'paramC',str2num(answer{2}), 'meanormedian',str2num(answer{3}),...
			'flare',str2num(answer{4}), 'min_area',str2num(answer{5}),'max_eccen', str2num(answer{6}), ...
			'min_circularity',str2num(answer{7}),...
			'channel_order',str2num(answer{8}),...
			'overlap',str2num(answer{9}),'labels1',answer{10},'labels2',answer{11},...
			'labels3',answer{12},'labels4',answer{13},'chan1method',str2num(answer{14}),...
			'chan2method',str2num(answer{15}),'chan3method',str2num(answer{16}),'chan4method',str2num(answer{17}));
		celllist = p;
	end;
	return;
end;

nameref = getnamerefs(inputs.ds,inputs.dirname);

tests = gettests(inputs.ds,nameref(1).name,nameref(1).ref);

Mask = {}; LabeledMask = {}; Contours = {};

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
		Mask{i} = adaptivethreshold(cellimage{i},parameters.localwindowsize,parameters.paramC,parameters.meanormedian);
		Mask{i} = bwmorph(Mask{i},'thicken',parameters.flare);
		LabeledMask{i} = bwlabel(Mask{i},4);
		Contours{i} = bwboundaries(Mask{i},4);
		[LabeledMask{i},goodinds] = removesmallspots(LabeledMask{i},parameters.min_area);
		Contours{i} = Contours{i}(goodinds);
		stats = regionprops(LabeledMask{i},'Eccentricity','Area','Perimeter');
		stats = regionprops_circularity(stats);
		goodinds2 = find(([stats(goodinds).Eccentricity] <= parameters.max_eccen) & ([stats(goodinds).Circularity]>= parameters.min_circularity));
		badinds2 = find( ([stats(goodinds).Eccentricity] > parameters.max_eccen) | ([stats(goodinds).Circularity] < parameters.min_circularity)  );
		for jj=1:length(badinds2),
			LabeledMask{i}(find(LabeledMask{i}==goodinds(badinds2(jj)))) = 0;
		end;
		Contours{i} = Contours{i}(goodinds2);
	else, error(['No image data for channel ' int2str(parameters.channel_order(i)) '.']);
	end;
end;

celllist = [];

for i=1:length(parameters.channel_order),
	labels = eval(['parameters.labels' int2str(parameters.channel_order(i))]);
	newcells = spots2celllist(LabeledMask{i}, inputs.dirname, inputs.cell_index_counter, labels, ...
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
		stats = regionprops(LabeledMask{j},'Eccentricity','Area','Perimeter');
		stats = regionprops_circularity(stats);
		goodinds2 = find(([stats(goodinds).Eccentricity] <= parameters.max_eccen) & ([stats(goodinds).Circularity]>= parameters.min_circularity));
		badinds2 = find( ([stats(goodinds).Eccentricity] > parameters.max_eccen) | ([stats(goodinds).Circularity] < parameters.min_circularity)  );
		for jj=1:length(badinds2),
			LabeledMask{j}(find(LabeledMask{j}==goodinds(badinds2(jj)))) = 0;
		end;
		Contours{j} = Contours{j}(goodinds2);
	end;
	if isempty(celllist), celllist = newcells; else, celllist = [celllist newcells]; end;
end;

