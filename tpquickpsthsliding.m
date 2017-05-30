function [mydata, myt, myavg, bins]=tpquickpsthsliding(dirname, channel, stimcodes, pixels, plotit, names,windowsize,stepsize,basemeth,blst)

% TPQUICKPSTH - Gives a peristimulus time histogram for one stimcode
%
%  [DATA, T, AVG, WINDOWTIMES]=TPQUICKPSTHSLIDING(DIRNAME, CHANNEL,
%       STIMCODES, PIXELS_OR_DATA, PLOTIT, NAMES, WINDOWSIZE,STEPSIZE,
%       BASELINEMETHOD,BLANKID)
%
%  Gives a peristimulus time histogram for stimcodes listed in
%  array STIMCODES.  If STIMCODES is empty, then all stimcodes are
%  used.
%
%  DIRNAME is the name of the test directory (e.g., 't00001').
%  CHANNEL is the channel number to read.
%  PIXELS_OR_DATA can be a cell list of pixel indices that specifies
%  areas of the image to be analyzed, or a struct with previously
%  extracted data.  If it is a struct, it should contain fields
%  'data' and 't' that are returned from TPREADDATA.
%  
%  PLOTIT indicates whether or not the data should be plotted.  If 
%  PLOTIT is 0, then data is not plotted.  If PLOTIT is 1, then the
%  individual entries are plotted.  If PLOTIT is 2, then the average
%  results are plotted (see AVG below).
%  NAMES should be a cell list of strings that should have as many entries
%  as PIXELS.  WINDOWSIZE is the size of a sliding window for computing average
%  responses and the standard deviation and standard error (in seconds).
%  STEPSIZE is the window step size (in seconds).
%
%  BASEELINEMETHOD specifies the baseline used to identify F in dF/F.
%  0 means spontaneous interval preceding each stimulus.
%  3 means filter the data and use the blank stimulus (if there is one)
%    for baseline.
%
%  BLANKID is the stimulus number of the blank stimulus, or [] for
%  automatic detection.
%
%  DATA is a cell list of the individual responses, T are the time points for
%  these responses.  The individual responses are themselves cell lists, 
%  divided into two rows corresponding to stimulus time and interstimulus
%  time.  For example, data{1}{5,1} are the fifth response values to the 
%  first stimulus during stimulus on time, and t{1}{5,1} is the time of
%  this response.  data{1}{5,2} is the fifth response during the
%  interstimulus interval.  Note that the stimulus responses will not
%  necessarily occur at even intervals because the frame sampling is not
%  necessarily in phase with the stimulus computer.
%
%  AVG is the average response in each time window.  AVG is a cell
%  matrix; AVG{i}{j} is the average response for cell i for stimulus j.
%
%  Steve VanHooser


if isempty(pixels), error(['No pixel regions specified.']); end;
stims = load([fixpath(dirname) filesep 'stims.mat'],'-mat');

s.stimscript = stims.saveScript; s.mti = stims.MTI2;

[s.mti,starttime]=tpcorrectmti(s.mti,[fixpath(dirname) filesep 'stimtimes.txt']);

do = getDisplayOrder(s.stimscript); do = do(1:fix(length(do)/2));

if isempty(stimcodes), stimcodes = 1:numStims(s.stimscript); end;

if nargin<9, baselinemethod = 0; else, baselinemethod = basemeth; end;
if nargin<10, blankstimid = []; else, blankstimid = blst; end;

if ~isempty(blankstimid), theblankid = blankstimid; else, theblankid = -1; end;

if theblankid==-1,
    for i=1:numStims(s.stimscript),
        if isfield(getparameters(get(s.stimscript,i)),'isblank'),
            theblankid = i;
            break;
        end;
    end;
end;

mydata = {}; myt = {};
masterint = []; masterspint = []; masterintind = []; masterspintind = [];
for j=1:length(stimcodes),
	%disp(['Stimcodes : ' int2str(stimcodes(j)) '.']);

	stimcodelocs = find(do==stimcodes(j));
   
	interval = [];
	spinterval = [];

	for i=1:length(stimcodelocs),
		interval(i,:) = [ s.mti{stimcodelocs(i)}.frameTimes(1) s.mti{stimcodelocs(i)}.startStopTimes(3)+10];
		dp = struct(getdisplayprefs(get(s.stimscript,do(stimcodelocs(i)))));
		if dp.BGposttime > 0,
			%spinterval(i,:)=[s.mti{stimcodelocs(i)}.startStopTimes(3) s.mti{stimcodelocs(i)}.startStopTimes(4)];
			spinterval(i,:)=[s.mti{stimcodelocs(i)}.startStopTimes(1)-dp.BGposttime+1 s.mti{stimcodelocs(i)}.startStopTimes(1)];
	        elseif dp.BGpretime > 0,
			spinterval(i,:)=[s.mti{stimcodelocs(i)}.startStopTimes(1) s.mti{stimcodelocs(i)}.frameTimes(1)];
       		end;
	end;

	masterint = [masterint ; interval]; 
	masterintind = [masterintind ; repmat(j,length(interval),1)];
	masterspint = [ masterspint ; spinterval];
	masterspintind = [masterspintind ; repmat(j,length(interval),1)];
end;

meanforbaselines = [];

if iscell(pixels),
	[data,t] = tpreaddata(dirname, [masterint ; masterspint]-starttime, pixels, 1,1);
else, 
    if baselinemethod==3,
        for p=1:size(pixels.data,2),
            [pixels.data{p},meanforbaselines(p)] = tpfilter(pixels.data{p},pixels.t{p});
        end;
    end;
    [data,t] = data2intervals(pixels.data,pixels.t,[masterint; masterspint]-starttime);
end;

%bins=min(0,min(masterspint(:,1)-masterint(:,1))):binsize:...
%		max(max(masterint(:,2)-masterint(:,1)),max(masterspint(:,2)-masterint(:,1)));
window_start = min(0,min(masterspint(:,1)-masterint(:,1)))-windowsize/2;
window_end = max(max(masterint(:,2)-masterint(:,1)),max(masterspint(:,2)-masterint(:,1)))+windowsize/2;

for j=1:length(stimcodes),
	theindssp = find(masterspintind==j);
	theinds = find(masterintind==j);
	for k=1:size(data,2),
		totalspont = [];
		for i=1:length(theindssp),
			totalspont = cat(1,totalspont,data{length(masterintind)+theindssp(i),k});
		end;
		meanspont = nanmean(totalspont);
        
        if baselinemethod==3,
            if theblankid>0,
                li = find(masterintind==theblankid);
                baseline = [];
                for jj=1:length(li),
                    baseline(end+1) = nanmean(data{li(jj),k});
                end;
                baseline = nanmean(baseline);
            else,
                baseline = meanforbaselines(k);
            end;
        end;

		newdata = {}; newt = {};
		newdatacat = []; newtcat = [];
		for i=1:length(theinds),
            if baselinemethod==0, baseline = nanmean(data{length(masterintind)+theindssp(i),k}); end;
			newdata{i,1}= (data{theinds(i),k}-baseline)/baseline;
			newt{i,1} = t{theinds(i),k} - (masterint(theinds(i),1)-starttime);
                        mynewtinds = find(~isnan(newt{i,1}));
			newdatacat = cat(1,newdatacat,newdata{i,1}(mynewtinds)); newtcat = cat(1,newtcat,newt{i,1}(mynewtinds));
		end;
		for i=1:length(theindssp),
            if baselinemethod==0, baseline = nanmean(data{length(masterintind)+theindssp(i),k}); end;            
			newdata{i,2}= (data{length(masterintind)+theindssp(i),k}-baseline)/baseline;
			newt{i,2} = t{length(masterintind)+theindssp(i),k} - (masterint(theinds(i),1)-starttime);
			mynewtinds = find(~isnan(newt{i,2}));
			newdatacat = cat(1,newdatacat,newdata{i,2}(mynewtinds)); newtcat = cat(1,newtcat,newt{i,2}(mynewtinds));
				% above assumes correspondence between theinds and theindssp
		end;
		mydata{j,k} = newdata;  myt{j,k} = newt;
		warns = warning('off');
		[Yn,Xn] = slidingwindowfunc(newtcat,newdatacat,window_start,stepsize,window_end,windowsize,'mean',1);
		bins = Xn';
		myavg{j,k} = Yn';
		warning(warns);
	end;
end;

if plotit,
	colors = [ 1 0 0 ; 0 1 0; 0 0 1; 1 1 0 ; 0 1 1; 1 0.5 1; 0.5 0 0 ; 0 0.5 0; 0 0 0.5; 0.5 0.5 0; 0.5 0.5 0.5];
	stimcodecell = {};
	for k=1:size(data,2),
		figure;
		hold on;
		for j=1:length(stimcodes),
			stimcodecell{j} = int2str(stimcodes(j));
			ind = mod(j,length(colors)); if ind==0, ind = length(colors); end;
			for i=1:size(colors,1), plot(0,0,'color',colors(i,:),'visible','off'); end;
			if plotit==1,
				for i=1:size(mydata{j,k},1),
                    if j==theblankid, lw=20; else, lw = 6; end;
					plot(myt{j,k}{i,1},mydata{j,k}{i,1},'.','color',colors(ind,:),'markersize',lw);
					plot(myt{j,k}{i,2},mydata{j,k}{i,2},'.','color',colors(ind,:),'markersize',lw);
				end;
			elseif plotit==2,
                if j==theblankid, lw=2; else, lw = 1; end;
				plot(bins,myavg{j,k},'','color',colors(ind,:),'linewidth',lw);
			end;
			legend(stimcodecell{:});
		end;
		title(names{k});
	end;
end;


