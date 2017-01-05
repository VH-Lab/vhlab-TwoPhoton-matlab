function [mti2,starttime] = tpcorrectmti(mti, filename,globaltime)

% TPCORRECTMTI - Correct NewStim MTI based on recorded times
%
% [MTI2,STARTTIME] = TPCORRECTMTI(MTI, FILENAME, [GLOBALTIME])
%
% Returns a time-corrected MTI timing file given actual timings
% recorded by a Plexon machine (exported Events). 
%
% The FILENAME argument is the full path to a file in the directory
% of interest. This argument will be used to obtain the directory only,
% the filename of the text file to be examined must be 'stimtimes_plexon.txt'.
% It should contain exported events from Plexon.
%
% GLOBALTIME is an optional argument.  If it is 1 then time is returned
% relative to the stimulus computer's clock.
%
% From FITZCORRECTMTI by Steve VanHooser
%

if nargin>2, globetime = globaltime; else, globetime = 0; end;

[dirname,fname] = fileparts(filename);

[stimids,stimtimes,frametimes] = read_stimtimes_plexon_txt(dirname);

% first check that we have the same number of stim triggers

if any(isnan(stimids)),
    if exist([dirname filesep 'stimtimes_plexon.mat']),
        m = load([dirname filesep 'stimtimes_plexon.mat'],'Strobed','-mat');
        stimids = m.Strobed(:,2);
    end;
end;

if length(stimtimes)~=length(mti),
	error(['Error in ' dirname ' processing: stim triggers present in the stimtimes_plexon.txt file (' int2str(length(stimtimes)) ') do not match what is expected from the contents of the stims.mat file (' int2str(length(mti)) '); try editing the stimtimes_plexon.txt file to correct the error.']);
end;

px_times = stimtimes;
px_stimids = stimids;
mac_times = [];
mac_stimids = [];
for i=1:length(mti),
	mac_times(end+1) = mti{i}.startStopTimes(2);
	if isfield(mti{i},'stimid'),
		mac_stimids(end+1) = mti{i}.stimid;
	else,
		mac_stimids(end+1) = NaN;
	end;
end;

if isempty(find(isnan(stimids))),
	if ~eqlen(stimids,mac_stimids),
		error(['The stimulus ID list in the stimtimes_plexon.txt file does not match that expected from the stims.mat file. Did you export to the correct directory?']);
	end;
end;

if length(mti)==1,
	px_times = frametimes{1};
	mac_times = mti{1}.frameTimes;
end;

reftime = stimtimes(1); % should be mti{1}.startStopTimes(2)

warnstate = warning('query');
warning off;
P = polyfit(mac_times(:),px_times(:),1);
warning(warnstate);

if 0,
	figure;
	plot(mac_times,px_times,'o');
	hold on;
	plot(mac_times,P(1)*mac_times+P(2),'g--');
end;

%fprintf(1,'P(1) is %0.15d\n',P(1));

  % slope is time_spike2 / time_mac

mti2 = mti;

et = mti2{1}.startStopTimes(1);

 % now convert back
for i=1:length(mti),
	mti2{i}.startStopTimes = et+(mti2{i}.startStopTimes-et)*P(1);
	mti2{i}.frameTimes = et+(mti2{i}.frameTimes-et)*P(1);
end;

starttime = mti2{1}.startStopTimes(2) - reftime; % this is when spike2 started, according to the Mac (in Mac seconds)

if globetime,  % if we want the output in Mac time, then we need to apply this shift
    [pathstr,name]=fileparts(filename);
    g = load([pathstr filesep 'stims']);
    for i=1:length(mti),
        mti2{i}.startStopTimes = mti2{i}.startStopTimes+g.start-starttime;
        mti2{i}.frameTimes = mti2{i}.frameTimes + g.start-starttime;
    end;    
end;
