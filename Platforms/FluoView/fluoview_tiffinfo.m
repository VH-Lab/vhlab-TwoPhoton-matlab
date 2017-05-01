function inf=fluoview_tiffinfo(imgname)
%FLUOVIEW_TIFFINFO parses image description information from Olympus Fluoview Multitiff 
%
% INF=FLUOVIEW_TIFFINFO( FNAME )
%
% 2008, Alexander Heimel & Danielle van Versendaal
%

inf=imfinfo(imgname);


% parsing inf.ImageDescription
% only of first info structure (subsequent tiffs have empty
% ImageDecription)

inf1=inf(1);

% numerical parameters
list={'PMT Voltage Ch1','Offset Ch1','Gain Ch1','PMT Voltage Ch2','Offset Ch2','Gain Ch2','Zoom Size','Scan Speed','SecondsPerScanLine','Gamma 0','Gamma 1','DisplayMode'};
for i=1:length(list)
	inf(1).(subst_filechars(list{i}))=eval(get_argument(inf1.ImageDescription,list{i}))
end

% text parameters
list={'Date','Time','Magnification','ScanMode','Scan Start Mode'};
for i=1:length(list)
	inf(1).(subst_filechars(list{i}))=get_argument(inf1.ImageDescription,list{i})
end

return

function arg=get_argument(regel,veldnaam)
a1=findstr(regel,veldnaam);
a2=find(regel(a1:end)=='=',1);
a3=find(regel(a1+a2:end)==13);
arg=trim(regel(a1+a2:a1+a2+a3))

