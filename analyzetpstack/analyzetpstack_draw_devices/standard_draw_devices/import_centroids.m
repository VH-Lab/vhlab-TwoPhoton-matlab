function celllist = import_centriods(parameters, inputs)

% IMPORT_CENTROIDS - Import a cell list from drawing of centroids.
%
%   CELLLIST = IMPORT_CENTROIDS(PARAMETERS, INPUTS)
%
%     PARAMETERS should be a structure with the following entries:
%         diameter                  Diameter to include around the centroid
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

celllist = [];

if nargin==0,
	prompt = {'Enter the diameter of the centroids to be drawn.'};
	name = 'Parameters for import_centroids function';
	numlines = 1;
	defaultanswer = {'8'};
	answer = inputdlg(prompt,name,numlines,defaultanswer);
	if ~isempty(answer),
		p = struct('diameter',str2num(answer{1}));
		celllist = p;
	end;
	return;
end;

 % 1) read in the centroid file

nameref = getnamerefs(inputs.ds,inputs.dirname);

tests = gettests(inputs.ds,nameref(1).name,nameref(1).ref);

candidate_filenames = {};

for i=1:length(tests),
	tpd = tpdirnames(tests{i});
	for j=1:length(tpd),
		fn = dir([getpathname(inputs.ds) filesep tpd{j} filesep '*esult*.xls']);
		for n=1:length(fn),
			candidate_filenames{end+1} = [getpathname(inputs.ds) filesep tpd{j} filesep fn(n).name];
		end;
	end;
end;

if length(candidate_filenames)==1,
	disp(['We only have one candidate file for Results.xls, so we will use it: ' candidate_filenames{1} '.']);
	resultsfile = candidate_filenames{1};
else,
	disp(['Cannot find one and only one candidate file for Results.xls, so I will ask the user.']);
	[resfile,respath] = uigetfile('*.xls','Select centroid file...');
	resultsfile = [respath filesep resfile];
end;

coor = xlsread(resultsfile);

  % editing here

 % 2) add the new cells

 % 2a) make a mesh image for obtaining index values

sz = size(inputs.previewim);
[blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));

 % 2b) loop over all centroid locations, adding a new cell

rad = round(parameters.diameter/2);
xi_ = ((-rad):1:(rad));
yi_p = sqrt(rad^2-xi_.^2);
yi_m = - sqrt(rad^2-xi_.^2);
dr = inputs.drift;

celllist = [];

for i=1:length(coor),
	x = coor(i,1);
	y = coor(i,2);
	xi = [xi_ xi_(end:-1:1)]+x+dr(1);
	yi = [yi_p yi_m(end:-1:1)]+y+dr(2);
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

