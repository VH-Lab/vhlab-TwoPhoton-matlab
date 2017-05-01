function [dr] = tpdriftcheck(dirname, channel, searchx, searchy, refdirname, refsearchx, refsearchy, howoften, avgframes, brightnesscorrect, roicorrect,subtractmean,brightnessartifact,writeit, doplotit)

%  TPDRIFTCHECK - Checks two-photon data for drift
%
%    [DR] = TPDRIFTCHECK(DIRNAME,CHANNEL,SEARCHX, SEARCHY,
%       REFDIRNAME,REFSEARCHX, REFSEARCHY, ...
%	HOWOFTEN,AVGFRAMES, BRIGHTNESSCORRECT, ROICORRECT,...
%       SUBTRACTMEAN, BRIGHTNESSARTIFACT, ...
%          WRITEIT, PLOTIT)
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
%  If BRIGHTNESSCORRECT is 1, then the images are normalized to their
%  means and spatial standard deviations (Z-score correction).
%
%  If ROICORRECT is 1, then every pixel that is less than the 
%    image mean and not next to a pixel that is greater than the
%    image mean is set to 0 to reduce its impact. 
%
%  If SUBTRACTMEAN is 1, then the mean is subtracted from the image before
%    alignment
%
%  If BRIGHTNESSARTIFACT is a number less than 100, then pixels below that
%  percentile will be set to the mean.
%
%  DR is a two-dimensional vector that contains the X and Y shifts for
%  each frame.
%
%  If PLOTIT is 1, the results are plotted in a new figure.
%
%  See also:  DRIFTCHECK

im0 = tppreview(refdirname,avgframes,1,channel);  % the first image

plotit = doplotit;
dirnames=tpdirnames( dirname );
thedirname = dirname;

for k=1:length(dirnames)

	dirname =  dirnames{k};

	params = tpreadconfig(dirname);
	if isfield(params,'Type'),
		if strcmp(params.Type,'linescan')|strcmp(params.Type,'Linescan'),
		dr = tpdriftcheckls(thedirname, channel, searchx, searchy, ...
			refdirname, refsearchx, refsearchy, howoften, avgframes, writeit, ...
			brightnesscorrect, [], doplotit);
		return
		end;
	end;
    
	n_timestamps=length(params.Image_TimeStamp__us_);

	tpfileparams = tpfnameparams(dirname,channel,params);
  
	ffile = repmat([0 0],n_timestamps,1);
	initind = 1;
	for i=1:params.Main.Total_cycles,
		numFrames = getfield(getfield(params,['Cycle_' int2str(i)]),'Number_of_images');
		ffile(initind:initind+numFrames-1,:) = [repmat(i,numFrames,1) (1:numFrames)'];
		initind = initind + numFrames;
	end;

	dr = []; t = [];
	drlast = [0 0];

	refisdifferent = ~strcmp(dirname,tpdirnames(refdirname));
	if refisdifferent,
		xrange = refsearchx; yrange = refsearchy;
	else,
		xrange = searchx; yrange = searchy;
	end;

	im1 =[];
	for f=1:howoften:n_timestamps-avgframes,
		fprintf(['Checking frame ' int2str(f) ' of ' int2str(n_timestamps) '.\n']);
		t(end+1) = 1;
		im1 = zeros(params.Main.Lines_per_frame,params.Main.Pixels_per_line,avgframes);
		for j=0:avgframes-1,
			im1(:,:,j+1)=tpreadframe(dirname,tpfileparams,ffile(f+j,1),channel,ffile(f+j,2));
		end;
		im1 = mean(im1,3);
		%size(im1), drlast(1,1)+xrange, drlast(1,2)+yrange,
		dr(length(t),[1 2]) = driftcheck(im0,im1,drlast(1,1)+xrange,drlast(1,2)+yrange,...
			'brightnesscorrect',brightnesscorrect, 'roicorrect', roicorrect,...
			'subtractmean',subtractmean,'brightnessartifact',brightnessartifact);
		refisdifferent = 0; % after first comparison, ref is NOT different anymore
		disp(['Searched ' int2str(drlast(1)+xrange) ' in x.']);
		disp(['Searched ' int2str(drlast(2)+yrange) ' in y.']);
		drlast = dr(length(t),[1 2]);
		disp(['Shift is ' int2str(dr(end,:))]);
		xrange = searchx; yrange = searchy;
	end;
    
	if writeit,
		newframeind = 1:length(params.Image_TimeStamp__us_);
		frameind = 1:howoften:length(params.Image_TimeStamp__us_)-avgframes;
	        if ~isempty(dr),
			drift=round([interp1(1:howoften:length(params.Image_TimeStamp__us_)-avgframes,dr(:,1),newframeind,'linear','extrap')' ...
				interp1(1:howoften:length(params.Image_TimeStamp__us_)-avgframes,dr(:,2),newframeind,'linear','extrap')';]);
		else, drift = [0 0];
	        end;
		save([dirname filesep 'driftcorrect'],'drift','-mat');
	end;

	if plotit&~isempty(im1),
		figure;
		subplot(2,2,1);
		image(rescale(im0,[min(min(im0)) max(max(im0))],[0 255])); colormap(gray(256));
		title('First image');
		subplot(2,2,2);
		im2 = (im0 / max(max(im0)));
		im2(:,:,2) = im1/max(max(im0));
		im2(:,:,3) = im2(:,:,1);
		im2(:,:,1) = zeros(size(im0));
		im2(find(im2>1)) = 1;
		image(im2);
		title('blue=first image, green = last image');
		subplot(2,2,3);
		plot(dr(:,1));
		title('X drift'); ylabel('Pixels'); xlabel('Frame #');
		subplot(2,2,4);
		plot(dr(:,2));
		title('Y drift'); ylabel('Pixels'); xlabel('Frame #');
	end;

end;
