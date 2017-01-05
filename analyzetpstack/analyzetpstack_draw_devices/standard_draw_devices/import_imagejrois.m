function celllist = import_imagejrois(parameters, inputs)

% IMPORT_CENTROIDS - Import a cell list from drawing of centroids.
%
%   CELLLIST = IMPORT_CENTROIDS(PARAMETERS, INPUTS)
%
%     PARAMETERS should be a structure with the following entries:
%         default_filename          The file of the ROIs (relative to the 2-photon image data)
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

celllist = [];

if nargin==0,
	prompt = {'Enter the default filename (local to 2-photon image data directory)'};
	name = 'Default ROI filename';
	numlines = 1;
	defaultanswer = {'RoiSet.zip'};
	answer = inputdlg(prompt,name,numlines,defaultanswer);
	if ~isempty(answer),
		p = struct('default_filename',str2num(answer{1}));
		celllist = p;
	end;
	return;
end;

 % 1) read in the filename
 
candidate_filenames = {};

candidate_filenames{end+1} = tpdirnames([getpathname(inputs.ds) filesep inputs.dirname]);
candidate_filenames{end} = [candidate_filenames{end}{1} filesep parameters.default_filename];

if length(candidate_filenames)==1 & exist(candidate_filenames{1}),
	disp(['We only have one candidate file for RoiSet.zip, so we will use it: ' candidate_filenames{1} '.']);
	resultsfile = candidate_filenames{1};
else,
	disp(['Cannot find one and only one candidate file, so I will ask the user.']);
	[resfile,respath] = uigetfile('*.zip','Select ImageJ ROI file...');
	resultsfile = [respath filesep resfile];
end;

rois = ReadImageJROI(resultsfile);

 % 2) add the new cells

 % 2a) make a mesh image for obtaining index values

sz = size(inputs.previewim);
[blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));

 % 2b) loop over all ROI locations, adding a new cell

dr = inputs.drift;

celllist = [];

t = linspace(0,2*pi);

for i=1:length(rois),
	x1 = rois{1,i}.vfEllipsePoints(1);
	y1 = rois{1,i}.vfEllipsePoints(2);
	x2 = rois{1,i}.vfEllipsePoints(3);
	y2 = rois{1,i}.vfEllipsePoints(4);
	e = 0; % eccentricity

	a = 0.5 * (sqrt((x2-x1)^2+(y2-y1)^2));
	b = a*sqrt(1-e^2);
	X = a*cos(t);
	Y = b*sin(t);
	w = atan2(y2-y1,x2-x1);

	xi = (x1+x2)/2 + X*cos(w) - Y*sin(w)  + dr(1);
	yi = (y1+y2)/2 + X*sin(w) + Y*cos(w) + dr(2);
	bw = inpolygon(blankprev_x,blankprev_y,xi,yi);

	newcell = analyzetpstack_emptycellrec;
	newcell.dirname = inputs.dirname;
	newcell.labels = inputs.default_label_strings;
	newcell.type = inputs.default_type_string;
	newcell.pixelinds = find(bw);
	newcell.xi = xi; newcell.yi = yi;
	newcell.index = inputs.cell_index_counter + i;
	if i==1,
		celllist = newcell;
	else,
		celllist(end+1) = newcell;
	end;
end;

 % that's it, we're done

