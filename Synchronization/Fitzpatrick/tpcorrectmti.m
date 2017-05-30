function [mti2,starttime] = tpcorrectmti(mti, filename,globaltime)

% TPCORRECTMTI - Correct NewStim MTI based on recorded times
%
% [MTI2,STARTTIME] = TPCORRECTMTI(MTI, STIMTIMEFILE,[GLOBALTIME])
%
%   Returns a time-corrected MTI timing file given actual timings
% recorded by the Spike2 machine and saved in a file named 
% STIMTIMEFILE.
%
% GLOBALTIME is an optional argument.  If it is 1 then time is returned
% relative to the stimulus computer's clock.
%
% This function will save its work to a file called 'tpcorrectmti_fitzpatrick.mat'
% and just read from this file if the modification date of 'filename' hasn't changed
% since it last checked.
% 
% From FITZCORRECTMTI by Steve Van Hooser
%

savefilename = 'tpcorrectmti_fitzpatrick.mat';

if nargin>2, globetime = globaltime; else, globetime = 0; end;

globaltime=globetime;

D = [];
filenameinfo = dir(filename);

[thepath] = fileparts(filename);
if exist([thepath filesep savefilename],'file'),
	z = load([thepath filesep savefilename]);
	if z.filenameinfo.datenum == filenameinfo.datenum & globaltime==z.globaltime,
		mti2 = z.mti2;
		starttime = z.starttime;
		return;
	end;
end;

fid = fopen(filename);

if fid<0, error(['Could not open file ' filename ', with error ' lasterr '.']); end;

 % first get multiplier between two timebases and then convert
sp2_times = [];
mac_times = [];
mac_stimid = [];
sp2_stimids = [];

i = 0;
if length(mti)>1, % if more than one stim, then use stim start times to calc
	while ~feof(fid),
	        i=i+1;
		stimline = fgets(fid);
		if ~isempty(stimline)&~eqlen(-1,stimline),
			stimdata = sscanf(stimline,'%f');
			if ~isempty(stimdata),
				try,
					sp2_stimids(end+1) = stimdata(1);
					sp2_times(end+1) = stimdata(2);
				catch,
					error(['error in  ' filename '.']);
				end;
		                try,
					mac_times(end+1) = mti{i}.startStopTimes(2);
				catch,
					error(['Error: there are extra stim triggers present in the stimtimes.txt (at least ' int2str(i) ') file as compared to what is expected from the content of stims.mat file (' int2str(length(mti)) ').']);
					%length(sp2_stimids), i,
					%keyboard;
				end;
				mac_stimid(end+1) = mti{i}.stimid;
				%disp(['Mac stim ' int2str(mac_stimid(end)) ', spike2 stim: ' int2str(stimdata(1)) '.']);
				%if mac_stimid(end)~=stimdata(1), error(['Stim order from stim computer does not match that recorded in Spike2 in filename ' filename]); end;
			end;
        	end;
	end;
else, % if less than one stim, then use frametimes to calc match
	stimline = fgets(fid);
	stimdata = sscanf(stimline,'%f');
	sp2_times = stimdata(3:end);
	mac_times = mti{1}.frameTimes';
	mac_stimid = mti{1}.stimid;
	if mac_stimid(end)~=stimdata(1),
		error(['Stim order from stim computer does not match that recorded in Spike2']);
	end;
end;


fseek(fid,0,'bof');
stimline = fgets(fid);
stimdata = sscanf(stimline,'%f');
reftime = stimdata(2);  % should be mti{1}.startStopTimes(2)
fclose(fid);

if length(mac_times)~=length(sp2_times),
	warning(['Number of stims reported by the stimulus computer (' int2str(length(mac_times)) ') does not match that recorded by Spike2 (' int2str(length(sp2_times)) '), using the first frames that match.']);
	mac_times = mac_times(1:length(sp2_times));
end;

warnstate = warning('query');
warning off;
P = polyfit(mac_times,sp2_times,1);
warning(warnstate);

if 0,
	figure;
	plot(mac_times,sp2_times,'o');
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

% now save material to the file

save([thepath filesep savefilename],'mti2','starttime','globaltime','filenameinfo','-mat');
