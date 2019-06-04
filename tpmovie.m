function M = tpmovie(dirname, channel, trials, thestims, sorted, diffnc, fps, filename) 
%  TPMOVIE - Movie of Prairieview two-photon data
%
%  MOVIE=TPMOVIE(DIRNAME, CHANNEL, TRIALS, STIMS, SORT, DIFF, FPS, FILENAME)
%
%    Computes a movie for two-photon data that is linked to the
%  stimulus presentation.  DIRNAME is the name of the directory.
%
%  CHANNEL is the channel to read.
%
% TRIALS is an array list of trial numbers to include.  The stimuli are assumed
%   to have been run in repeating blocks.  If this argument is not present or is
%   empty then all trials are included.
%
% STIMS is an array list of stim numbers to include. If this argument is not
%   present or is empty then all stimuli are included.
%
% SORT is 0/1; if it is 1, then the stimuli are shown in numerical order.
% DIFF is 0/1; if it is 1, then the difference between the first five frames
%        and the remaining frames are shown; otherwise, the raw data is shown.
%
% FPS is the frames-per-second viewing rate of the movie.
%
% FILENAME is the name of the output AVI file.

if exist([fixpath(dirname) 'stims.mat'])~=2,
	fitzlabstiminterview(dirname);
end;
stims = load([fixpath(dirname) filesep 'stims.mat'],'-mat');
s.stimscript = stims.saveScript; s.mti = stims.MTI2;
[s.mti,starttime]=tpcorrectmti(s.mti,[fixpath(dirname) filesep 'stimtimes.txt']);
do = getDisplayOrder(s.stimscript);

tottrials = length(do)/numStims(s.stimscript);

if isempty(trials),
	trials = 1:tottrials;
end;
if isempty(thestims),
	thestims = 1:numStims(s.stimscript);
end;
do_analyze_i = [];

for i=1:length(trials),
	thistrial = fix(1+(trials(i)-1)*length(do)/tottrials):fix(trials(i)*length(do)/tottrials);
	[dummy,thesestims] = intersect(do(thistrial),thestims);
	thesestims = sort(thesestims);
	do_analyze_i = cat(2,do_analyze_i,thistrial(thesestims));
end;

if sorted,
	[dummy,newinds] = sort(do(do_analyze_i));
	do_analyze_i = do_analyze_i(newinds);
end;

notvisited = 1:length(do_analyze_i);

interval = [];

while ~isempty(notvisited),
	di = diff(do_analyze_i(notvisited));
	norun = find(di~=1);
	if isempty(norun),
		rununtil = notvisited(end);
	else,
		rununtil = notvisited(norun(1));
	end;
	%notvisited(1), rununtil,
	interval(end+1,:) = [s.mti{do_analyze_i(notvisited(1))}.startStopTimes(2) - 4 ...
				s.mti{do_analyze_i(rununtil)}.startStopTimes(3) + 4 ];
	notvisited = (rununtil+1):length(do_analyze_i);
end;

pv=tppreview(dirname,5,1,channel);
im=zeros(size(pv));
im(15:end-15,15:end-15)=1;
pixels=find(im==1);
im=im(15:end-15,15:end-15);
pv=pv(15:end-15,15:end-15);

[data,t] = tpreaddata(dirname,interval-starttime,{pixels},0,channel);

figure('position',[100 100 size(im,1) size(im,2)+150]); H = gcf;
ax1 = axes('units','pixels','position',[0 50 size(im,1) 150]); % for stim data
[stimgraph, stimlabels] = stimscriptgraph(dirname,1);
ax2 = axes('units','pixels','position',[0 150 size(im,1) size(im,2)+150]); % for image data
colormap(gray(256));

ind_s = find(stimgraph(:,2)==1);
stimints = reshape(stimgraph(ind_s,1),2,length(stimgraph(ind_s,1))/2)';

mx=0; mn=10000;
for i=1:size(interval,1),
	frameshere = reshape(data{i,1},size(im,1),size(im,2),length(data{i,1})/(size(im,1)*size(im,2)));
	for k=1:size(frameshere,3),
		myframe = conv2((frameshere(:,:,k)-diffnc*pv),ones(1,1)/(sum(sum(ones(1,1)))),'same');
		mxh=max(max(myframe));
		mnh=min(min(myframe));
		mx=max([mxh mx]);mn=min([mnh mn]);
	end;
end;
 

if diffnc,
	mn= 0;
end;
M = struct('cdata',[],'colormap',[]); M = M([]);

hh = [];

for i=1:size(interval,1),
	frameshere = reshape(data{i,1},size(im,1),size(im,2),length(data{i,1})/(size(im,1)*size(im,2)));
	timehere = reshape(t{i,1},size(im,1),size(im,2),length(data{i,1})/(size(im,1)*size(im,2)));

	for k=1:size(frameshere,3),
		tm = sum(sum(timehere(:,:,k)))/(size(im,1)*size(im,2));
		axes(ax1); 
		if ishandle(hh), delete(hh); end;
		hold on; hh = plot([tm tm],[0 3],'k--');
		axis([tm-3 tm+3 0 4]);
		if ~isempty(find(stimints(:,1)<=tm&stimints(:,2)>=tm)),
			set(ax1,'Color',[1 0 0]);
		else,
			set(ax1,'Color',[1 1 1]);
		end;
		ch=get(ax1,'children');
		set(ax1,'children',[ch(2:end);ch(1)]);
		axes(ax2);
		cla; 
		myframe = conv2((frameshere(:,:,k)-diffnc*pv),ones(1,1)/(sum(sum(ones(1,1)))),'same');
		image(rescale(myframe,[mn 3000],[0 256]));
		set(ax2,'xtick',[],'ytick',[]);
		M(end+1) = getframe(H);
	end;
end;

movie2avi(M,filename,'FPS',fps,'compression','none');

close(H);

