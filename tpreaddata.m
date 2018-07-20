function [data, t,frametimes, roidata] = tpreaddata(dirname, intervals, pixelinds, mode, channel)

% TPREADDATA - Reads twophon data
%
%  [DATA, T] = TPREADDATA(DIRNAME, INTERVALS, PIXELINDS, MODE)
%
%  Reads data blocks from PrairieView record.  TPREADDATA
%  allows the user to request data in specific time intervals
%  and at specific locations in the image.
%
%  DIRNAME is the directory name where files are kept
%  INTERVALS is a matrix specifying time intervals to read,
%     each row specifies a time interval:
%     e.g., INTERVALS = [ 4 5 ; 6 7] indicates to read data
%     between 4 and 5 seconds and also between 6 and 7 seconds
%     time 0 is relative to the beginning of the scans in the
%     directory
%  PIXELINDS is a cell list specifying pixel indices to read
%     from the images.  Each entry should contain the
%     pixel indices for a given region.
%  MODE is the data mode.  It can be the following:
%     0 : Individidual pixel values are returned.
%     1 : Mean data and time for each frame is returned.
%     2 : Values for each pixel index are returned, and if
%            there are no values for that pixel then NaN
%            is returned at those indices.
%     3 : Mean value of each pixel is returned; no
%            individual frame data is recorded.  Any frames
%            w/o data or w/ NaN are excluded.  Time points
%            will be equal to the mean time recorded as well.
%     10: Individidual pixel values are returned, including
%           frames that only have partial data (i.e., when
%           scan is traversing the points to be read at the
%           beginning or end of an interval).
%     11: Mean data and time for each frame is returned,
%           including frames that have partial data.
%           (Note that this could mean that different numbers
%           of pixels are averaged during each frame.)
%     21: Mean data of all responses over all time intervals
%           is returned.
%
%  CHANNEL is the channel number to be read, from 1 to 4.
%
%  DATA is an MxN cell list, where M is the number of time
%  intervals and N is the number of pixel regions specified.
%  T is also an MxN cell list that contains the exact sample
%  times of each point in DATA.
%
%  If there is a file in the directory called 'driftcorrect',
%  then it is loaded and the corrections are applied.
%  (See TPDRIFTCHECK.)
%
%  Tested:  only tested for T-series records, not other types

dirnames=tpdirnames(dirname);

% lets find parameter files, get the file name prefix pattern
params = {}; fnameprefix = {}; 

for i=1:length(dirnames),
  params{i} = tpreadconfig(dirnames{i});
  fnameparameters{i}=tpfnameparams(dirnames{i},channel,params{i});
end;

if isfield(params{1},'Type'),
    if strcmp(params{1}.Type,'Linescan'),
        [data, t,frametimes,roidata]= tpreadlsdata(dirname, intervals, pixelinds, mode, channel);
        return;
    end;
end;

[frametimes,frame2dirnum] = tpcorrecttptimes(params,dirname);

 % now read in which frames correspond to which file names (file names have a cycle number and cycle frame number)
ffile = repmat([0 0],length(frametimes),1);
dr = [];
initind = 1;

for j=1:length(dirnames),
	for i=1:params{j}.Main.Total_cycles,
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

 % these variables will be used to calculate the time of each pixel within a frame
currScanline_period__us_ = 0; currLines_per_frame = 0;
currDwell_time__us_ = 0; currPixels_per_line = 0;

ims = cell(1,length(frametimes));
imsinmem = zeros(1,length(frametimes));

 % frame 29, row 29
%global test test2 pt;
%test = frametimes(29)+pixeltimes(29,1);
%test2 = frametimes(232)+pixeltimes(106,128);
%pt = pixeltimes;

drewframe = 0;

[dummy,intervalorder] = sort(intervals(:,1));  % do intervals in order to reduce re-reading of frames

data = cell(size(intervals,1),length(pixelinds));
t= cell(size(intervals,1),length(pixelinds));
roidata = cell(size(intervals,1),length(pixelinds));

if mode==21,
	for i=1:length(pixelinds), accum{i} = zeros(size(pixelinds{i})); taccum{i}=zeros(size(pixelinds{i})); numb(i)=0; end;
	data = cell(1,length(pixelinds));
	t= cell(1,length(pixelinds));
end;
for j=1:size(intervals,1),
	if mode==3,
		for i=1:length(pixelinds),
			accum{i}=zeros(size(pixelinds{i}));
			taccum{i}=zeros(size(pixelinds{i}));
			numb(i)=0;
		end;
	end;
	if (intervals(intervalorder(j),1)<frametimes(1)) && (intervals(intervalorder(j),2)>frametimes(1)),
		f0 = 1;
	else,
		f0=find(frametimes(1:end-1)<=intervals(intervalorder(j),1)&frametimes(2:end)>=intervals(intervalorder(j),1));
	end;
	if intervals(intervalorder(j),2)>frametimes(end)&intervals(intervalorder(j),1)<frametimes(end),
		f1 = length(frametimes);
	else,
		f1=find(frametimes(1:end-1)<=intervals(intervalorder(j),2)&frametimes(2:end)>=intervals(intervalorder(j),2));
	end;
	%f0,f1,
	for f=f0:f1,
		dirid = frame2dirnum(f);  % find the directory where frame number f resides
		if sum(imsinmem)>299,  % limit 300 frames in memory at any one time
			inmem = find(imsinmem);
			ims{inmem(1)} = []; imsinmem(inmem(1)) = 0;
		end;
		if ~imsinmem(f),
			try
				[ims{f},fname]=tpreadframe(dirnames{dirid},fnameparameters{dirid},ffile(f,1),channel,ffile(f,2));
				imsinmem(f) = 1;
			catch
				error(['There was an error reading a frame from ' fname ', message ' lasterr '.']);
			end;
		end;
		if (currScanline_period__us_ ~= params{dirid}.Main.Scanline_period__us_) || ...
			(currLines_per_frame ~= params{dirid}.Main.Lines_per_frame) ||...
			(currDwell_time__us_ ~= params{dirid}.Main.Dwell_time__us_)|| ...
			(currPixels_per_line ~= params{dirid}.Main.Pixels_per_line)

			%update pixeltimes, time within each frame that each pixel was recorded
			pixeltimes = + repmat( (0 : params{dirid}.Main.Scanline_period__us_*1e-6 : ...
				(params{dirid}.Main.Lines_per_frame-1)*params{dirid}.Main.Scanline_period__us_*1e-6  )', ...
				1,params{dirid}.Main.Pixels_per_line);

			pixeltimes = pixeltimes + repmat( 0: (params{dirid}.Main.Dwell_time__us_*1e-6) : ...
				((params{dirid}.Main.Pixels_per_line-1)*params{dirid}.Main.Dwell_time__us_*1e-6), ...
				params{dirid}.Main.Lines_per_frame,1);
      
			%pixeltimes = pixeltimes - params{dirid}.Main.Frame_period__us_*1e-6;  % if trigger is end-of-frame marker

			currScanline_period__us_ = params{dirid}.Main.Scanline_period__us_;
			currLines_per_frame = params{dirid}.Main.Lines_per_frame;
			currDwell_time__us_=params{dirid}.Main.Dwell_time__us_;
			currPixels_per_line=params{dirid}.Main.Pixels_per_line;
		end;
		t_ = frametimes(f)+pixeltimes;
		for i=1:length(pixelinds),
			if ~isempty(dr),
				[ii,jj]=ind2sub(size(ims{f}),pixelinds{i});
				try,
					thepixelinds = sub2ind(size(ims{f}),ii-dr(f,2),jj-dr(f,1));
					% out of bounds will give an error
				catch,
					thepixelinds = [];
				end;
			else, thepixelinds = pixelinds{i};
			end;
			try,
				thisdata = double(ims{f}(thepixelinds));
			catch,
				disp(['Cell index: ' int2str(i) ', reading frame ' int2str(f) ', length of pixinds ' int2str(length(thepixelinds)) '.']);
				thepixelinds,
			end;
			thistime = t_(thepixelinds);
			newtinds = find(thistime>=intervals(intervalorder(j),1)&thistime<=intervals(intervalorder(j),2)); % trim out-of-bounds points
			%newtinds = 1:numel(thepixelinds); % if we ignore the frame time edge effects, usually not good
			if mode==1,
				if length(newtinds)==length(thepixelinds),
					thistime = thistime(newtinds); thisdata = thisdata(newtinds);
					thistime = nanmean(thistime); thisdata = nanmean(thisdata);
				else, thistime = []; thisdata = [];
				end;
			elseif mode==0,
				if length(newtinds)==length(thepixelinds),
					thistime = thistime(newtinds);
					thisdata = thisdata(newtinds);
				else,
					thistime = [];
					thisdata = [];
				end;
			elseif mode==3|mode==21,
				if length(newtinds)==length(thepixelinds),
					thistime = thistime(newtinds);
					thisdata = thisdata(newtinds);
				else,
					thistime = [];
					thisdata = [];
				end;
				if ~isempty(thistime),
					accum{i}=nansum(cat(3,accum{i},thisdata),3);
					taccum{i}=nansum(cat(3,taccum{i},thistime),3);
					numb(i)=numb(i)+1;
				end;
			elseif mode==11,
				thistime = thistime(newtinds); thisdata = thisdata(newtinds);
				if ~isempty(newtinds),
					thistime = nanmean(thistime); thisdata = nanmean(thisdata);
				else, thistime = []; thisdata = [];
				end;
			elseif mode==10,
				thistime = thistime(newtinds); thisdata = thisdata(newtinds);
			elseif mode==2,
				badinds = setdiff(1:length(thepixelinds),newtinds);
				thisdata(badinds) = NaN;
			end;
			%[thistime,newtinds] = sort(thistime); % sort samples by time
			%thisdata = thisdata(newtinds);
			if (mode~=3)&(mode~=21),
				data{intervalorder(j),i} = cat(1,data{intervalorder(j),i},reshape(thisdata,prod(size(thisdata)),1));
				t{intervalorder(j),i} = cat(1,t{intervalorder(j),i},reshape(thistime,prod(size(thisdata)),1));
			end;
			roidata{intervalorder(j),i}{end+1} = thepixelinds;
		end;
	end;
	if mode==3,
		for i=1:length(pixelinds),
			if numb(i)>0,
				data{intervalorder(j),i} = accum{i}/numb(i);
				t{intervalorder(j),i} = taccum{i}/numb(i);
			else,
				data{intervalorder(j),i} = NaN * ones(size(pixelinds{i}));
				t{intervalorder(j),i} = NaN * ones(size(pixelinds{i}));
			end;
		end;
	end;
end;
if mode==21,
	for i=1:length(pixelinds),
		if numb(i)>0,
			data{1,i} = accum{i}/numb(i);
			t{1,i} = taccum{i}/numb(i);
		else,
			data{1,i} = NaN * ones(size(pixelinds{i}));
			t{1,i} = NaN * ones(size(pixelinds{i}));
		end;
	end;
end;

for i=1:length(ims), ims{i} = []; end; clear ims; pack;
