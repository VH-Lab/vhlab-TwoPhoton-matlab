function [drref,drls] = tpdriftcheckls(thedirname, channel, searchx, searchy, refdirname, refsearchx, refsearchy, howoften, avgframes, writeit, brightnesscorrect, domedfilter, doplotit)

%  TPDRIFTCHECKLS - Checks two-photon linescan data for drift
%
%    [DRREF,DRLS] = TPDRIFTCHECKLS(DIRNAME,CHANNEL,SEARCHX, SEARCHY,
%       REFDIRNAME,REFSEARCHX, REFSEARCHY, ...
%	HOWOFTEN,AVGFRAMES, WRITEIT, PLOTIT)
%
%  Reports drift across a twophoton time-series record.  Drift is
%  calculated by computing the correlation for pixel shifts within
%  the search space specified.  SEARCHX and SEARCHY are vectors
%  containing offsets from 0 (no drift).  REFSEARCHX and
%  REFSEARCHY are the offsets to check during the initial
%  effort to find a match between frames acquired in different
%  directories.
%
%  DIRNAME is the directory in which to check for drift
%  relative to data at the beginning of data
%  in REFDIRNAME.  CHANNEL is the channel to be read.
%
%  The fraction of frames to be searched is specified in HOWOFTEN.  If
%  HOWOFTEN is 1, all frames are searched; if HOWOFTEN is 10, only one
%  of every 10 frames is searched.
%
%  AVGFRAMES specifies the number of frames to average together.
%
%  If WRITEIT is 1, then a 'driftcorrect.mat' file is written to the
%  directory, detailing shifted frames.
%
%  DRREF is a two-dimensional vector that contains the X and Y shifts for
%  the reference frame, and DRLS contains X and Y shifts for each line.
%
%  If PLOTIT is 1, the results are plotted in a new figure.

im0 = tppreview(refdirname,avgframes,1,channel);  % the reference image

if ~isempty(domedfilter),
    if domedfilter~=0,
        im0 = medfilt2(im0,[domedfilter domedfilter]);
    end;
    imagedisplay(im0);
end;

plotit = doplotit;

drtot = [];

dirnames=tpdirnames( thedirname );


for k=1:length(dirnames)

	dirname =  dirnames{k},

	params = tpreadconfig(dirname);
	n_timestamps=length(params.Image_TimeStamp__us_);
  
	tpfileparams = tpfnameparams(dirname,channel,params);
  
	ffile = repmat([0 0],n_timestamps,1);
	initind = 1;
	for i=1:params.Main.Total_cycles,
		numFrames = getfield(getfield(params,['Cycle_' int2str(i)]),'Number_of_images');
		ffile(initind:initind+numFrames-1,:) = [repmat(i,numFrames,1) (1:numFrames)'];
		initind = initind + numFrames;
	end;

	drref = [0 0];
	drlast = [0 0];

	if strcmp(thedirname,refdirname), % this is base directory
	else,
		im1 = tppreview(thedirname,avgframes,1,channel);
		drref(1,[1 2]) = driftcheck(im0,im1,refsearchx,refsearchy,'brightnesscorrect',1);
	end;

	for f=1:n_timestamps,
		fprintf(['Checking frame ' int2str(f) ' of ' int2str(n_timestamps) '.\n']);
		im1=double(tpreadframe(dirname,tpfileparams,ffile(f,1),channel,ffile(f,2)));
		numlines = size(im1,1);
		starts = 1:howoften:numlines-1;
		stops = howoften:howoften:numlines;
		if isempty(stops)|(stops(end)<numlines & length(stops)<length(starts)),
			stops(end+1) = numlines;
		end;
		drvals = [];
		for i=1:length(starts),
			mnln = nanmean(im1(starts(i):stops(i),:));
			drvals(end+1,:) = driftcorrectls(im0, params.Linescanpoints, mnln, drlast(1)+searchx, drlast(2)+searchy, brightnesscorrect);
			drlast = drvals(end,:);
		end;
		drls{f} = [interp1( (starts+stops)/2,drvals(:,1),1:numlines,'linear','extrap')' interp1((starts+stops)/2,drvals(:,2),1:numlines,'linear','extrap')'];
		drtot = [drtot; drls{f}];
	end;

	if writeit,
        drift = drref;
		save([dirname filesep 'driftcorrect'],'drift','drls','-mat');
	end;
end;

if plotit,
    figure;
    subplot(2,2,1);
    image(rescale(im0,[min(min(im0)) max(max(im0))],[0 255])); colormap(gray(256));
    title('First image');

    subplot(2,2,2);

    plot(drtot(:,1));
    title('X drift'); ylabel('Pixels'); xlabel('Line #');
    subplot(2,2,4);
    plot(drtot(:,2));
    title('Y drift'); ylabel('Pixels'); xlabel('Line #');
end;

