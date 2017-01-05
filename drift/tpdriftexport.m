function b = tpdriftexport(tpdirname, channel, exportfilename, varargin)
%TPDRIFTEXPORT - Export a TIFF stack of motion-corrected images from a 2-photon record
%
%  B = TPDRIFTEXPORT(TPDIRNAME, CHANNEL, EXPORTFILENAME, ...)
%
%  Exports a 'TIFF' stack movie of the 2-photon data in TPDIRNAME on
%  channel CHANNEL. The data is written to EXPORTFILENAME in the TPDIRNAME directory.
%
%  If the file 'driftcorrect' is present in the 2-photon directory,
%  the drift-correction is applied.
%
%  B is 1 if the operation succeeds.
%
%  This function also accepts additional arguments in the form of name/value pairs.
%  Name (default value) :  Description
%  --------------------------------------------------------------------------
%  GraphicalProgress (1):  Show progress bar
%  

GraphicalProgress = 1;

assign(varargin{:});

b = 0;

dirnames = tpdirnames(tpdirname);

params = {}; 

for i=1:length(dirnames),
	params{i} = tpreadconfig(dirnames{i});
	fnameparameters{i} = tpfnameparams(dirnames{i},channel,params{i});
end;

[frametimes,frame2dirnum] = tpcorrecttptimes(params,tpdirname);
ffile = repmat([0 0],length(frametimes),1);
dr = [];
initind = 1;

for j=1:length(dirnames),
	for i=1:1:params{j}.Main.Total_cycles,
		numFrames = getfield(getfield(params{j},['Cycle_' int2str(i)]),'Number_of_images');
		ffile(initind:initind+numFrames-1,:) = [repmat(i,numFrames,1) (1:numFrames)'];
		initind = initind + numFrames;
	end;
	if exist([dirnames{j} filesep 'driftcorrect']),
		drfile = load([dirnames{j} filesep 'driftcorrect'],'-mat');
		dr = [dr; drfile.drift];
	elseif ~isempty(dr),  % will trigger if previous driftcorrect but not one in dirnames{j}
		error(['Directory ' dirnames{j} ' lacks a driftcorrect file, but other ' dirname '-### directories have a driftcorrect file.  Drift correction must be all or none.']);
	end;
end;


dirid = 1;

if GraphicalProgress,
	progressbar(['Drift export of ' tpdirname ]);
end;

writestring = 'overwrite';

for f=1:length(frametimes),
	im = tpreadframe(dirnames{dirid}, fnameparameters{dirid}, ffile(f,1), channel, ffile(f,2));
	%disp(['reading frame ' int2str(f) '...']);
	im2 = imshift(im, [dr(f,2), dr(f,1)]);
	imwrite(im2,[dirnames{dirid} filesep exportfilename],'tif','WriteMode',writestring);
	writestring = 'append';
	if GraphicalProgress,
		progressbar(f/length(frametimes));
	end;
end;

b = 1;
