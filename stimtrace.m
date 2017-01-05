function stimtrace(dirname,cellno)
% stimtrace(dirname,cellno)
% 
% Extracts raw delta-F/F trace for each presentation of each stim, and
% plots. Must be run from 'analysis\scratch' folder, and requires
% tpreaddata (from standard bulkload analysis panel) to have been 
% previously run (this can be acheived through Analyze by param, stim #, or
% raw buttons).
% 
% Returns the max, min, and mode of the number of frames collected for each
% stimuli. Attempts to truncate available frames to set length frameint. If
% stimulation lasted longer than frameint, a dot will be plotted on the
% first data point of the post-stim ISI indicating that the stimuli was
% still on when that data point was collected. 
%
% Can return data = m x 3*frameint x n array, n=stim number, with each m x frameint array
% containing deltaF/F for each presentation. Frameint is number of frames
% to take for each interval. 
% Hardcoded for current parameters as frameint=3.
%
% INPUTS: dirname is identifier of image set (eg 't00001')
%     cellno is number of cell.
% 
% GS 8_4_10

%% load data
% first check the path:
if isempty(strfind(cd,'analysis\scratch')); 
    try 
        cd 'analysis\scratch'
    catch
        error('stimtrace must be run from analysis\scratch directory!')
    end
end
% Now find and load the raw data (from tpreaddata)
dirlist=dir(cd);
filelist={dirlist.name};
k=[];
for i=1:length(filelist)
    if ~isempty(strfind(filelist{i},dirname))
        if ~isempty(strfind(filelist{i},'_raw'))
            k=[k i];
        end
    end
end
if length(k)~=1; error('Unclear file list: no unique / exact match found. Check filename'); end
q=load(filelist{k},'-mat');
% convert cellno into cellnoindex - the array in raw only contains info for
% cells in this slice, thus if cell 5 isn't present in slice 2 then data{5}
% is actually data for cell number 6. We have to look at the list of cell
% names that is stored in the raw data file to find the correct index. - GS
cellnoIndex=find(~cellfun(@isempty,strfind(q.listofcellnames,['cell ' num2str(cellno) ' '])));
if length(cellnoIndex)~=1; error(['Couldn''t find exact match for cellno. Found ' ...
        num2str(length(cellnoIndex)) ' matches']); end
disp(q.listofcellnames{cellnoIndex})
raw=q.data{cellnoIndex};
t=q.t{cellnoIndex};
clear q k dirlist filelist i
%%
% Now get stim timings
scratchpath=cd;
cd ..
cd .. % moves up to root date dir (not elegant, and error prone. should fix later)
exppath=[cd filesep dirname];
cd(exppath);
sfile=load('stims.mat');
do = getDisplayOrder(sfile.saveScript);
[s.mti starttime]=tpcorrectmti(sfile.MTI2,'stimtimes.txt');
cd(scratchpath);
%%
frameint=3; % sets number of frames to be taken for blank and stim periods
data=zeros(length(do)/numStims(sfile.saveScript),3*frameint,8);
numstimframes=zeros(8*length(do)/numStims(sfile.saveScript),1); % will contain num frames per stim for every presenation
numintframes=zeros(8*length(do)/numStims(sfile.saveScript),1); % will contain number of frames per ISI
overrunframes=[]; % will contain indices (in data) of stims where there were actually frameint+1 stims 
% (so end of stim is actually first frame of "postISI")
badFirstIsi=false;
%%
for j=1:8
    stimind=find(do==j);
    for i=1:length(stimind)
        stimints=[s.mti{stimind(i)}.frameTimes(1) s.mti{stimind(i)}.startStopTimes(3)]-starttime;
        stimframes=find(t>stimints(1) & t<stimints(2));
        if stimind(i)==1; 
            % if no obvious prev interval (ie for first stim)
            % take frameint number of preceeding frames
            intframes=[stimframes(1)-frameint:stimframes(1)-1]';
            numintframes((j-1)*length(stimind)+i)=numel(intframes);
        else
            intframes=find(t>s.mti{stimind(i)-1}.startStopTimes(3)-starttime ...
                & t<stimints(1));
        end
        % Get original number of samples for stim and ISI
        numintframes((j-1)*length(stimind)+i)=numel(intframes);
        numstimframes((j-1)*length(stimind)+i)=numel(stimframes);
%         disp(['Stim: ' num2str(j) ', trial: ' num2str(i) ', stimframes: ' num2str(numel(stimframes))])
        % reduce number of samples to frameint (same for both)
        if length(intframes)>frameint; intframes=intframes(end-(frameint-1):end); end
        if length(stimframes)>frameint; 
            stimframes=stimframes(1:frameint); 
            overrunframes=[overrunframes; [j i]]; %overrun frames j=stimID, I=trial number 1-8
        end
        if ~isempty(intframes(intframes<0))
            intframes=intframes(intframes>0); % only does anything if we didn't capture enough frames before the first stim
            badFirstIsi=true;
            firstframes=length(intframes(intframes>0));
        end
        while length(intframes)<frameint %pad intframes if there weren't enough frames collected
            intframes=[intframes(1) ; intframes];
        end
        % take frameint number of frames after stimulus
        if length(stimframes)<frameint
            postintframes=[stimframes(end)+1:stimframes(end)+(frameint+(frameint-length(stimframes)))]';
        else
            postintframes=stimframes+frameint;
        end
        
        %  data as deltaf / f
try
        data(i,:,j)=(raw([intframes; stimframes; postintframes]')-mean(raw(intframes(1:3))))/mean(raw(intframes(1:3)));
catch
    intframes(1)=1;
            data(i,:,j)=(raw([intframes; stimframes; postintframes]')-mean(raw(intframes(1:3))))/mean(raw(intframes(1:3)));
            disp('not enough frames before first stim')
end

end
end
% display data on number of frames collected:
disp(['Intervals: Max: Min: Mode:'])
disp(['Stim       ' num2str([max(numstimframes) min(numstimframes) mode(numstimframes)])])
disp(['Pre-ISI    ' num2str([max(numintframes) min(numintframes) mode(numintframes)])])
if min([min(numstimframes) min(numintframes)])<frameint
    disp('WARNING: trials exist without minimum number of frames!')
end
if badFirstIsi
        disp(['WARNING: not enough baseline frames collected before first stim. Only ' ...
            num2str(firstframes) ' frame collected!'])
end
%% Plot data
figure('name',['Raw traces for cell ' num2str(cellno) ', file ' dirname],'position',[255 130 807 669])
for i=1:8
    subplot(2,4,i)
    plot(1:3*frameint,data(:,:,i))
    hold on
    means=mean(data(:,:,i),1);
    plot(1:3*frameint,means,'k','linewidth',2)
    errs=sem(data(:,:,i),1);
    line([1:3*frameint;1:3*frameint],[means+errs;means-errs],'color','k')  
end
% Highlight overrun frames
y=colormap('lines');
for i=1:size(overrunframes,1)
    subplot(2,4,overrunframes(i,1))
    scatter(frameint*2+1,data(overrunframes(i,2),frameint*2+1,overrunframes(i,1)),...
        'marker','d','markeredgecolor',y(overrunframes(i,2),:),...
        'markerfacecolor',y(overrunframes(i,2),:),'sizedata',15)
end
% make it pretty:
deglist=0:45:315;
oldylims=zeros(8,2);
for i=1:8
    subplot(2,4,i)
    oldylims(i,:)=ylim;
%     ylim;
end
for i=1:8
    subplot(2,4,i)
    newylim=[min(oldylims(:,1)) max(oldylims(:,2))];
    ylim(newylim)
    xlim([1 3*frameint])
    ylabel('deltaF/F')
    xlabel('Frame number')
    line([frameint+1 2*frameint],[newylim(1) newylim(1)],'color','k','linewidth',5)
    box off
    title([num2str(deglist(i)) ' deg'])
end
