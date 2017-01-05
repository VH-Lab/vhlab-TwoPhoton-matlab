function [mydata, myt, myavg, bins]=tpquickpsth(dirname, channel, stimcodes, pixels, plotit, names,binsize)

% TPQUICKPSTH - Gives a peristimulus time histogram for one stimcode
%
%  [DATA, T, AVG, BINS]=TPQUICKPSTH(DIRNAME, CHANNEL,
%       STIMCODES, PIXELS_OR_DATA, PLOTIT, NAMES, BINSIZE)
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
%  'data' and 't' that are returned from READTPDATA.
%  
%  PLOTIT indicates whether or not the data should be plotted.  If 
%  PLOTIT is 0, then data is not plotted.  If PLOTIT is 1, then the
%  individual entries are plotted.  If PLOTIT is 2, then the average
%  results are plotted (see AVG below).
%  NAMES should be a cell list of strings that should have as many entries
%  as PIXELS.  BINSIZE is the size of time bins for computing average
%  responses and the standard deviation and standard error.
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
%  AVG is the average response in each time bin in BINS.  AVG is a cell
%  matrix; AVG{i}{j} is the average response for cell i for stimulus j.
%

if isempty(pixels), error(['No pixel regions specified.']); end;
stims = load([fixpath(dirname) filesep 'stims.mat'],'-mat');

s.stimscript = stims.saveScript; s.mti = stims.MTI2;

[s.mti,starttime]=tpcorrectmti(s.mti,[fixpath(dirname) filesep 'stimtimes.txt']);

do = getDisplayOrder(s.stimscript); do = do(1:fix(length(do)/2));

if isempty(stimcodes), stimcodes = 1:numStims(s.stimscript); end;

mydata = {}; myt = {};
masterint = []; masterspint = []; masterintind = []; masterspintind = [];
for j=1:length(stimcodes),
	%disp(['Stimcodes : ' int2str(stimcodes(j)) '.']);

	stimcodelocs = find(do==stimcodes(j));
   
	interval = [];
	spinterval = [];

	for i=1:length(stimcodelocs),
		interval(i,:) = [ s.mti{stimcodelocs(i)}.frameTimes(1) s.mti{stimcodelocs(i)}.startStopTimes(3)+5];
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

if iscell(pixels),
	[data,t] = tpreaddata(dirname, [masterint ; masterspint]-starttime, pixels, 1,1);
else, [data,t] = data2intervals(pixels.data,pixels.t,[masterint; masterspint]-starttime);
end;

%bins=min(0,min(masterspint(:,1)-masterint(:,1))):binsize:...
%		max(max(masterint(:,2)-masterint(:,1)),max(masterspint(:,2)-masterint(:,1)));
firstbins = [0:-binsize:min(0,min(masterspint(:,1)-masterint(:,1)))];
secondbinds = [binsize:binsize:max(max(masterint(:,2)-masterint(:,1)),max(masterspint(:,2)-masterint(:,1)))];
bins = [firstbins(end:-1:1) secondbinds];
bins = [bins(1)-binsize bins bins(end)+binsize];

sums = zeros(size(bins));

for j=1:length(stimcodes),
	theindssp = find(masterspintind==j);
	theinds = find(masterintind==j);
	for k=1:size(data,2),
		totalspont = [];
		for i=1:length(theindssp),
			totalspont = cat(1,totalspont,data{length(masterintind)+theindssp(i),k});
		end;
		meanspont = nanmean(totalspont);

		newdata = {}; newt = {};
		sumavg = sums;
		numavg = sums;
		for i=1:length(theinds),
			newdata{i,1}= (data{theinds(i),k}-nanmean(data{length(masterintind)+theindssp(i),k}))/nanmean(data{length(masterintind)+theindssp(i),k});
			newt{i,1} = t{theinds(i),k} - (masterint(theinds(i),1)-starttime);
			mynewtinds = find(~isnan(newt{i,1}));
			if ~isempty(find(~isnan(newdata{i,1}))),
				sumavg(1+round( (newt{i,1}(mynewtinds)-bins(1))/binsize)) = ...
					sumavg(1+round( (newt{i,1}(mynewtinds)-bins(1))/binsize)) + ...
					newdata{i,1}(mynewtinds)';
				numavg(1+round( (newt{i,1}(mynewtinds)-bins(1))/binsize)) = ...
					numavg(1+round( (newt{i,1}(mynewtinds)-bins(1))/binsize)) +1; 
			end;
		end;
		for i=1:length(theindssp),
			newdata{i,2}= (data{length(masterintind)+theindssp(i),k}-nanmean(data{length(masterintind)+theindssp(i),k}))/nanmean(data{length(masterintind)+theindssp(i),k});
			newt{i,2} = t{length(masterintind)+theindssp(i),k} - (masterint(theinds(i),1)-starttime);
			mynewtinds = find(~isnan(newt{i,2}));
				% above assumes correspondence between theinds and theindssp
			if ~isempty(find(~isnan(newdata{i,2}))),
				sumavg(1+round( (newt{i,2}(mynewtinds)-bins(1))/binsize)) = sumavg(1+round( (newt{i,2}(mynewtinds)-bins(1))/binsize)) + ...
					newdata{i,2}(mynewtinds)';
				numavg(1+round( (newt{i,2}(mynewtinds)-bins(1))/binsize)) = numavg(1+round( (newt{i,2}(mynewtinds)-bins(1))/binsize)) +1; 
			end;
		end;
		mydata{j,k} = newdata;  myt{j,k} = newt;
		warns = warning('off');
		myavg{j,k} = sumavg ./ numavg; 
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
					plot(myt{j,k}{i,1},mydata{j,k}{i,1},'.','color',colors(ind,:));
					plot(myt{j,k}{i,2},mydata{j,k}{i,2},'.','color',colors(ind,:));
				end;
			elseif plotit==2,
				plot(bins-0.5*binsize,myavg{j,k},'','color',colors(ind,:));
			end;
			legend(stimcodecell{:});
		end;
		title(names{k});
	end;
end;
