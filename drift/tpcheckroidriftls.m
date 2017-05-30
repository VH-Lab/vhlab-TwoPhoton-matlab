function [im] = tpcheckroidriftls(dirname, channel, roiinds, roix, roiy, roiname, plotit)

%  TPCHECKROIDRIFTLS - Checks twophoton drift correction performance on linescan data
%
%  IM = TPROIDRIFT(DIRNAME,CHANNEL,ROIINDS,ROIX,ROIY,RIONAME, PLOTIT)
%
%  Checks drift correction performance.  Takes a rectangle (ROIRECT) as input and
%  then grabs the image of this rectangle from each two-photon frame.  If an
%  object of interest is within this rectangle, the ROIINDS and the X and Y
%  coordinates (relative to the center of ROIRECT) can be specified and the
%  object will be outlined.
%  If the data are to be plotted (PLOTIT==1) then the axes are titled with ROINAME.
%
%  CHANNEL is the channel to be read.

 % Step 1 - extract parameters, the reference image, etc

[pv,params] = tppreview(dirname,1,1,channel);

dirnames_tp = tpdirnames(dirname);

if isfield(params,'Type'),
	if ~strcmp(params.Type,'Linescan')&~strcmp(params.Type,'linescan'),
		error(['Data in directory ' dirname ' do not appear to be linescan data.']);
	end;
end;

 % Step 2 - determine frame numbers, and read drift values

n_timestamps=length(params.Image_TimeStamp__us_);
ffile = repmat([0 0],n_timestamps,1);
initind = 1;
for i=1:params.Main.Total_cycles,
	numFrames = getfield(getfield(params,['Cycle_' int2str(i)]),'Number_of_images');
	ffile(initind:initind+numFrames-1,:) = [repmat(i,numFrames,1) (1:numFrames)'];
	initind = initind + numFrames;
end;

fname_drift = [dirnames_tp{1} filesep 'driftcorrect.mat'];

if exist(fname_drift)==2,
	d = load(fname_drift,'-mat');
	dr = [ d.drls{1}(1,:) ];
else,
	dr = [0 0];
end;


 % Step 3 - read the first frame and open the explorer

tpfileparams = tpfnameparams(dirnames_tp{1},channel,params);
im1=double(tpreadframe(dirnames_tp{1},tpfileparams,ffile(1,1),channel,ffile(1,2)));
tplinescandriftexplorer('dirname',dirnames_tp{1},'rasterimage',pv,...
	'linescanpoints',params.Linescanpoints,...
	'uncorrectedlinescanimage',im1,'defaultdrift',dr);

 % Step 4 -  loop over all frames in all directories

for k=1:length(dirnames_tp),

	dname = dirnames_tp{k};

	if k~=1, % we've already loaded these for k==1
		params = tpreadconfig(dname);
		tpfileparams = tpfnameparams(dname,channel,params);
		n_timestamps=length(params.Image_TimeStamp__us_);
		ffile = repmat([0 0],n_timestamps,1);
		initind = 1;
		for i=1:params.Main.Total_cycles,
			numFrames = getfield(getfield(params,['Cycle_' int2str(i)]),'Number_of_images');
			ffile(initind:initind+numFrames-1,:) = [repmat(i,numFrames,1) (1:numFrames)'];
			initind = initind + numFrames;
		end;
	end;

	if exist([dname filesep 'driftcorrect']),
		d = load([dname filesep 'driftcorrect'],'-mat');
		dr = d.drift;
		drls = d.drls;
	else,
		drls = [];
	end;

	tagname =['linescan' int2str(fix(10000*rand))];
	callback=['tpcheckroidriftls_matchx(''' tagname ''');'];

	% assume number of linescans in first frame is representative, let's put at least 1024 per image
	frames_per_drift_image = max(1,floor(1024/size(im1,1)));

	f = 1;
	while f<n_timestamps+1,
		im = [];
		mydrls = [];
		kk = 1;
		framestart = f;
		while kk<frames_per_drift_image & f<n_timestamps+1,
			im=[im; double(tpreadframe(dname,tpfileparams,ffile(f,1),channel,ffile(f,2)))];
			if ~isempty(drls),
				mydrls = [mydrls; drls{f}];
			end;
			kk = kk+1;
			f = f+1;
		end;
		figure('tag',tagname);
		plotrasterroionlinescan(im,size(pv),roiinds,params.Linescanpoints,mydrls);
		title([roiname ': drift for linescan frames ' int2str(framestart) ' to ' int2str(f-1)  ...
				' of ' int2str(n_timestamps)  '.'],'interp','none');
		ax = gca; % the current axes will be the one the image is drawn in
		set(ax,'position',[0.1 0.2 0.8 0.7]);
		uicontrol('style','pushbutton','units','normalized','position',[0.1 0.05 0.3 0.1],...
			'string','Match X axis','callback',callback,'tag','MatchXAxisBt');
	end;

	% need a function that plots the ROI on an image
end;

im = 0;

return;

havestims = 0;

if exist([fixpath(dirname) 'stims.mat'])==2, havestims = 1; end;

if havestims,
	stims = load([fixpath(dirname) filesep 'stims.mat'],'-mat');
	s.stimscript = stims.saveScript; s.mti = stims.MTI2;
	[s.mti,starttime]=tpcorrectmti(s.mti,[fixpath(dirname) filesep 'stimtimes.txt']);
end;

%figure;subplot(2,2,1);  image(rescale(pv,[min(min(pv)) max(max(pv))],[0 255])); subplot(2,2,2); image(256*im0); colormap(gray(256));

%interval = [ s.mti{1}.frameTimes(1)-3 s.mti{end}.startStopTimes(3) ]-starttime;
%interval = [ 40 100];
interval = [0 Inf];

[data,t] = tpreaddata(dirname, [interval],{rectinds roiinds},0,channel);


im = reshape(data{1,1},rctx,rcty,length(data{1,1})/(rctx*rcty));
t_ = reshape(t{1,1},rctx,rcty,length(data{1,1})/(rctx*rcty));
t_ = reshape(t_,rctx*rcty,length(data{1,1})/(rctx*rcty));
ims = reshape(data{1,2},length(roiinds),length(data{1,2})/length(roiinds));
t2 = reshape(t{1,2},length(roiinds),length(t{1,2})/length(roiinds));

numframes = size(im,3); i = 1;

im1 = mean(im(:,:,1:min(5,numframes)),3);
  
drt = [0 0 mean(t_(:,1))];

if plotit,
	while i<numframes,
		framestart = i;
		im_ = zeros(10*size(im,1),10*size(im,2));
		ctr = [ ];
		for j=1:10,
			for k=1:10,
				if i<numframes,
					im_(1+(j-1)*size(im,1):j*size(im,1),1+(k-1)*size(im,2):k*size(im,2))=im(:,:,i);
					ctr(end+1,[1:2])=[median(1+(j-1)*size(im,1):j*size(im,1)) median(1+(k-1)*size(im,2):k*size(im,2))];
                   	if mod(i,3)==0,
                        im2 = mean(im(:,:,i:min(i+5,numframes)),3);
						drt(end+1,:) = [driftcheck(im1,im2,[-10:2:10],[-10:2:10],'brightnesscorrect',1,'roicorrect',0) mean(t_(:,i))];
					end;
					i = i + 1;
				end;
			end;
		end;
		frameend = i;
		imagedisplay(im_); hold on;
		if ~isempty(roix),
			for j=1:size(ctr,1),
				plot(roix+ctr(j,2),roiy+ctr(j,1),'b-');
			end;
		end;
		title(['Extracted frame ' int2str(framestart) ' to ' int2str(frameend) ' of ' roiname '.']);
	end;
	figure;
	subplot(4,1,1);
	plot(drt(:,3),drt(:,1),'r'); hold on; plot(drt(:,3),drt(:,2),'b');
	title(['Drift statistics for ' roiname ' : red is x, blue is y.']);

	subplot(4,1,2);
	plot(mean(t2,1),mean(ims,1),'k-o'); 
	title('Value at each time point.');
	A = axis;
    
	subplot(4,1,3);
	plot(mean(t2,1),mean(ims,1)/max(mean(ims,1)),'k-o');
	hold on;
	if havestims, stimscriptgraph(dirname,1); end;
	axis([A(1:2) 0 3]);
    
	subplot(4,1,4);
	plot(mean(t_,1)',1:numframes,'k-o');
	title(['Relationship between time and frames']); 
	xlabel('Time (s)'); ylabel('Frame (#)');
end;
