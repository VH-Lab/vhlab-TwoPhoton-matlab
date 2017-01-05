function [resp] = tptuningcurve(dirname, channel, paramname, pixels, plotit, names, trials, tint,sptint, blst, basemeth)

%  TPTUNINGCURVE - Tuning curve for PrairieView two-photon data
%
%  RESPS = TPTUNINGCURVE(DIRNAME, CHANNEL, PARAMETER, PIXELS_OR_DATA, PLOTIT, NAMES,
%            [TRIALS], [T0 T1],[SP0 SP1],BLANKSTIMID,BASELINE_METHOD)
%
%    Computes mean responses, standard deviations, standard error, and
%  individual responses for a directory of PrairieView two-photon data that
%  also has NewStim stimulus data associated with it.
%
%  DIRNAME is the directory where the data resides.  CHANNEL is the
%  channel number of data to read.
%
%  PARAMETER is the name of the parameter to be examined (e.g., 'angle' for
%  the angle of a periodicstim).  Alternatively, the user can specify [] and
%  output values will be numbered from 1 .. number of stimuli.
%  The data are averaged over the entire course of the stimulus presentation.
%
%  PIXELS_OR_DATA can either be a cell list that specifies areas of the image
%  to be analyzed, or a struct with previously extracted data.
%  If it is a cell list of pixels, then each entry should be indices
%  corresponding to the pixels in each region.  If it is a struct, it should
%  contain fields 'data' and 't' that are returned from TPREADDATA.
%
%  Any interstimulus time is used to compute spontaneous activity.
%
%  If PLOTIT is 1 then data are plotted with titles given in cell list NAMES.
%  There should be one entry in NAMES for each set of pixel indices.
%  
% RESPS is a structure of length (PIXELS) with the following entries:
%
%    'curve' is a matrix with four rows; the first row contains the
%      data point labels, the second row contains the mean response
%      value divided by the mean spontaneous value, the third row
%      is the standard deviation, and the fourth row is standard error
%
%    'ind' is a cell list that contains all individual responses for
%      each stimulus.  This is dF/F.
%   
%    'spont' is a vector with the mean, standard deviation, and
%       standard error measured over the interstimulus time
%
%    'indspont' is a vector containing the individual responses during the
%    spontaneous periods.
%
%    'indf' is a vector containing the individual responses for each
%      stimulus.  This is F.
%
%    'blankresp' is a vector containing mean, standard deviation, and standard
%       error of responses during a blank trial, if it exists
%    'blankind' is a list of individual responses to the blank condition
%
% TRIALS is an array list of trial numbers to include.  The stimuli are assumed
%   to have been run in repeating blocks.  If this argument is not present or is
%   empty then all trials are included.
%
% [T0 T1] is the time interval to analyze relative to stimulus onset.  If this
%   argument is not present or empty then the stimulus duration is analyzed.
% 
% [SP0 SP1] is the time interval to analyze for computing the resting state
%   relative to stimulus onset. Default if not specified or if empty is specified
%   is to analyze the interval 2 seconds after the last stimulus until stimulus
%   onset.
%
%  BLANKSTIMID is the ID of a stim to consider the blank stimulus.  If EMPTY then
%    stimulus parameters are examined for the presence of an 'isblank' field.
%    If none is found, then no stimulus is considered blank.
%
%  BASELINEMETHOD determines how the baseline is calculated:
%     0  - Use the data collected during the previous ISI
%     1  - Use the closest blank stimulus
%     2  - Use a 20s window of ISI and blank values.
%     3  - Filter data with 240s highpass and use mean
%
%  

if nargin<7, thetrials = []; else, thetrials = trials; end;
if nargin<8, timeint= []; else, timeint = tint; end;
if nargin<9, sponttimeint= []; else, sponttimeint= sptint; end;
if nargin<10, blankstimid = []; else, blankstimid = blst; end;
if nargin<11, baselinemethod = 0; else, baselinemethod = basemeth; end;

if ~isempty(blankstimid), theblankid = blankstimid; else, theblankid = -1; end;

interval = [];
spinterval = [];

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

meanforbaselines = [];

if iscell(pixels),
	[data,t] = tpreaddata(dirname, [interval; spinterval]-starttime, pixels,0, channel);
else,
    if baselinemethod==3,
        for p=1:size(pixels.data,2),
            [pixels.data{p},meanforbaselines(p)] = tpfilter(pixels.data{p},pixels.t{p});
        end;
    end;
	[data,t] = data2intervals(pixels.data,pixels.t,[interval; spinterval]-starttime);
end;

for p=1:size(data,2),
	curve = []; spcurve = []; indspont = []; ind = {}; indf = {}; indspontt = []; indspontm = []; indsponttm = [];
	blankd = []; blankt = []; blankdm = []; blanktm = [];

	for i=(size(interval,1)+1):(size(interval,1)+size(spinterval,1)),
		indspont = cat(1,indspont,data{i,p});
		indspontt = cat(1,indspontt,t{i,p});
		indspontm = cat(1,indspontm,nanmean(data{i,p}));
		indsponttm = cat(1,indsponttm,nanmean(t{i,p}));
	end;
	spont = [ nanmean(indspont) nanstd(indspont) nanstderr(indspont) ];

	if theblankid==-1,
		for i=1:numStims(s.stimscript),
			if isfield(getparameters(get(s.stimscript,i)),'isblank'),
				theblankid = i;
				break;
			end;
		end;
	end;
	if theblankid>0,
		li = find(do(do_analyze_i)==theblankid);
		for j=1:length(li),
			mn = data{li(j),p};
			blankd = cat(1,blankd,mn);
			blankt = cat(1,blankt,t{li(j),p});
			blankdm = cat(1,blankdm,nanmean(mn));
			blanktm = cat(1,blanktm,nanmean(t{li(j),p}));
		end;
	end;

    if baselinemethod==3,
        if theblankid>0,
            baseline = repmat(nanmean(blankdm),1,(size(interval,1)+size(spinterval,1)));
        else, baseline = repmat(meanforbaselines(p),1,(size(interval,1)+size(spinterval,1)));
        end;
    else,
        baseline = compute_baseline(interval(:,1)-starttime,baselinemethod,indspont,indspontt,indspontm,indsponttm,blankd,blankt,blankdm,blanktm);
    end;
    
	myind = 1;
	for i=1:numStims(s.stimscript),
		if theblankid~=i,
			li = find(do(do_analyze_i)==i);
			if ~isempty(li), % make sure the stim was actually shown
				ind{myind} = []; indf{myind} = [];
				for j=1:length(li),
					mn = nanmean(data{li(j),p}');
					%ind{myind} = cat(1,ind{myind},(mn-indspont(li(j)))/indspont(li(j)));
					ind{myind} = cat(1,ind{myind},(mn-baseline(li(j)))/baseline(li(j)));
					indf{myind} = cat(1,indf{myind},mn);
				end;
				if isempty(paramname),
					curve(1,myind) = myind;
				else, curve(1,myind) = getfield(getparameters(get(s.stimscript,i)),paramname);
				end;
				curve(2,myind) = nanmean(ind{myind});
				curve(3,myind) = nanstd(ind{myind});
				curve(4,myind) = nanstderr(ind{myind});
				myind = myind + 1;
			end;
		else,
			li = find(do(do_analyze_i)==i);
			blankind = [];
			for j=1:length(li),
				mn = nanmean(data{li(j),p}');
				%blankind = cat(1,blankind,(mn-indspont(li(j)))/indspont(li(j)));
				blankind = cat(1,blankind,(mn-baseline(li(j)))/baseline(li(j)));
			end;
			blankresp = [nanmean(blankind) nanstd(blankind) nanstderr(blankind)];
		end;
	end;
 
  	if exist('blankresp')==1,
		newstruct = struct('curve',curve,'ind',{ind},'spont',spont,'indspont',indspont,...
			'blankresp',blankresp,'blankind',blankind,'indf',{indf});
	else,
		newstruct = struct('curve',curve,'ind',{ind},'spont',spont,'indspont',indspont,'indf',{indf});
	end;
	resp(p) = newstruct;
    % plotit = 0;
	if plotit,
        if mod(p-1,4*4)==0, figure('position',[70 0 1131 836]); end;
        subplot(4,4,1+mod(p-1,4*4));
		plot(curve(1,:),curve(2,:),'k-','linewidth',2,'hittest','off');
		hold on;
		h=myerrorbar(curve(1,:),curve(2,:),curve(4,:),curve(4,:));
        mymx = nanmax(curve(2,:)+curve(4,:));
        mymn = nanmin(curve(2,:)-curve(4,:));
		delete(h(2)); set(h(1),'linewidth',2,'color',0*[1 1 1]);
		if exist('blankresp')==1, % plot blank response if it exists
			a = axis;
			plot([-1000 1000],blankresp(1)*[1 1],'k-','linewidth',1,'hittest','off');
			plot([-1000 1000],[1 1]*(blankresp(1)-blankresp(3)),'k--','linewidth',0.5,'hittest','off');
			plot([-1000 1000],[1 1]*(blankresp(1)+blankresp(3)),'k--','linewidth',0.5,'hittest','off');
            mymn2 = min(blankresp(1)-blankresp(3),blankresp(1)+blankresp(3));
            mymx2 = max(blankresp(1)-blankresp(3),blankresp(1)+blankresp(3));
            mymx = max(mymx,mymx2); mymn = min(mymn,mymn2);
			axis(a); % make sure the axis doesn't get changed on us
		end;
		xlabel(paramname); ylabel('\delta F/F');
		title(names{p});
        myxmin = min(curve(1,:)-nanmean(diff(sort(curve(1,:)))));
        myxmax = max(curve(1,:)+nanmean(diff(sort(curve(1,:)))));
        try,
            axis([myxmin myxmax mymn-0.1*abs(mymx-mymn) mymx+0.1*abs(mymx-mymn)]);
        catch,
        end;
        set(gca,'buttonDownFcn',{@plotStimTrace dirname});
	end;
end;

function plotStimTrace(obj,evo,pathname)
% first: make sure we're in the right directory for the plotted tuning
% curves (in case we accidently navigated away at some point)
cd(pathname) % points to folder containing stim times. We need to be up one level
% in order for stimtrace to find the correct analysis/scratch folder
cd .. 
k=strfind(pathname,filesep); k=k(end)+1;
dirname=pathname(k:end);
% now extract cell number and directory name from axis plot
str=get(get(obj,'title'),'string');
spaces=strfind(str,' ');
cellno=str2num(str(spaces(1)+1:spaces(2)-1));

% run stimtrace
stimtrace(dirname,cellno);
