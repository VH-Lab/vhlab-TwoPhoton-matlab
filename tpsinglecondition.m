function [result,indimages] = tpsinglecondition(dirname, channel, thetrials, timeint, sponttimeint, plotit,name)

%  TPSINGLECONDITION - Simple image math
%
%  [RESULT,INDIMAGES] = TPSINGLECONDITION(DIRNAME,CHANNEL,
%        TRIALLIST,[T0 T1], [SP0 SP1], PLOTIT,NAME)
%
%    Computes simple image math for twophoton images.
%
%  DIRNAME is the name of a two-photon directory.  It should not include
%  the string '-001' that PrairieView adds to its directory names.
%  CHANNEL is the channel number to read.
%
%  
%  TRIALLIST is the trial numbers to include.  If it is empty, all
%     trials are included.
%
%  [T0 T1] is the time interval to analyze relative to stimulus onset.  If this
%   argument is empty then the stimulus duration is analyzed.
%
%  [SP0 SP1] is the time interval to analyze for computing the resting state
%   relative to stimulus onset. Default if empty is to analyze the
%   interval 2 seconds after the last stimulus until stimulus
%   onset.
%
%  INDIMAGES are individual single condition images in a cell list.
%  They are the same size as the images in DIRNAME, less 35*2 pixels
%  on a side that are trimmed.  These pixels are trimmed so that
%  the entire frame can be read even after drift correction.
%  Images that drift by more than 35 pixels will not be included in
%  the images.
%
%  RESULT is a cell list of composites of INDIMAGES, each one
%  containing a 3x3 composite of images in INDIMAGES.
%
%  If PLOTIT is 1, then the data is plotted as an image with title
%  NAME.

interval = []; spinterval = [];

if exist([fixpath(dirname) 'stims.mat'])~=2,
        fitzlabstiminterview(dirname);
end;
stims = load([fixpath(dirname) filesep 'stims.mat'],'-mat');
s.stimscript = stims.saveScript; s.mti = stims.MTI2;
[s.mti,starttime]=tpcorrectmti(s.mti,[fixpath(dirname) filesep 'stimtimes.txt']);
do = getDisplayOrder(s.stimscript);

tottrials = length(do)/numStims(s.stimscript);

if isempty(thetrials), do_analyze_i = 1:length(do);
else,
        do_analyze_i = [];
        for i=1:length(thetrials),
                do_analyze_i = cat(2,do_analyze_i,...
	                fix(1+(thetrials(i)-1)*length(do)/tottrials):fix(thetrials(i)*length(do)/tottrials));
        end;
end;

for i=1:length(do_analyze_i),
        stimind = do_analyze_i(i);
        if ~isempty(timeint),
                interval(i,:) = s.mti{stimind}.frameTimes(1) + timeint;
        else,
                interval(i,:) = [ s.mti{stimind}.frameTimes(1) s.mti{stimind}.startStopTimes(3)];
        end;

        dp = struct(getdisplayprefs(get(s.stimscript,do(i))));
        if ~isempty(sponttimeint),
                spinterval(i,:) = s.mti{stimind}.frameTimes(1) + sponttimeint;
        else,
          if dp.BGposttime > 0,  % always analyze before time
                spinterval(i,:)=[s.mti{stimind}.startStopTimes(1)-dp.BGposttime+1 s.mti{stimind}.startStopTimes(1)];
                spinterval(i,:)=[s.mti{stimind}.startStopTimes(1)-dp.BGposttime+1 s.mti{stimind}.startStopTimes(1)];
          elseif dp.BGpretime > 0,
                spinterval(i,:)=[s.mti{stimind}.startStopTimes(1) s.mti{stimind}.frameTimes(1)];
          end;
        end;
end;

im = tppreview(dirname,2,1,channel);
im_outline = zeros(size(im));
im_outline(35:end-35,35:end-35) = 1;
pixinds = {find(im_outline==1)};
im_outline = 0*im_outline(35:end-35,35:end-35);
 % now sort into individual stims

for i=1:numStims(s.stimscript),
	disp(['Now working on image ' int2str(i) '.']);
	li = find(do(do_analyze_i)==i);
	myintervals = interval(li,:);
	myspintervals = spinterval(li,:);
	data = tpreaddata(dirname,myintervals-starttime,pixinds,21,channel);
	datasp = tpreaddata(dirname,myspintervals-starttime,pixinds,21,channel);
	indimages{i} = data{1,1} - datasp{1,1};
	indimages{i} = reshape(indimages{i},size(im_outline,1),size(im_outline,2));
	indimages{i} = conv2(indimages{i},ones(5)/sum(sum(ones(5))),'same');
end;

if 0,
for i=1:numStims(s.stimscript),
	li = find(do(do_analyze_i)==i);
	myim = im_outline;
	if ~isempty(li),
		indimages{i}=nanmean(cat(3,data{li,1}),3)-nanmean(cat(3,data{li+size(interval,1),1}),3);
		indimages{i}=reshape(indimages{i},size(im_outline,1),size(im_outline,2));
		indimages{i}=conv2(indimages{i},ones(5)/sum(sum(ones(5))),'same');
	end;
end;
end;

i = 1; r = 1;
while i<=numStims(s.stimscript),
	imstart = i;
	im_ = zeros(3*size(indimages{1},1),3*size(indimages{1},2));
	ctr = [ ];
	for j=1:3,
		for k=1:3,
			if i<=numStims(s.stimscript),
				im_(1+(j-1)*size(indimages{i},1):j*size(indimages{i},1),1+(k-1)*size(indimages{i},2):k*size(indimages{i},2))=indimages{i};
				ctr(end+1,[1:2])=[median(1+(j-1)*size(indimages{i},1):j*size(indimages{i},1)) median(1+(k-1)*size(indimages{i},2):k*size(indimages{i},2))];
				i=i+1;
			end;
		end;
	end;
	imend = i-1;
	if plotit,
		imagedisplay(im_,'Title',['Single conditions ' int2str(imstart) ' to ' int2str(imend) ' of ' name '.']);
	end;
	result{r} = im_;
	r = r + 1;
end;
