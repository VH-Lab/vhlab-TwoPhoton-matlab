function params = readprairieviewxml3(filename)

% READPRAIRIEXML3 - Read parameters from a PrairieView vers 3 file
%
%
%  Reads important parameters from a PrairieView vers 3 file.

fid = fopen(filename,'rt');

if (fid==-1),
	error(['Could not open file ' filename '.']);
end;

version = readPVScanVersion(fid);

[imagetimes, imagespercycle, tscycind, lscycind,meatind] = GetFrameTimes(fid,0,version);

if version(1)==5 & version(2)==5,
	meatind = 1;
end;

if length(tscycind)>0 & length(lscycind)==0,
	% assume each cycle is the same; not necessarily true for complex records
	params.Type = 'Time series';
elseif length(lscycind)>0 & length(tscycind)==0,
	params.Type = 'Linescan';
else,
	error(['Do not yet know how to deal with mixed linescan and tseries data; extend me!']);
end;

params.Main.Total_cycles = length(imagespercycle);
params.Main.Scanline_period__us_ = 1e6*readprairie3keyvalue(fid,'scanlinePeriod',meatind(1),500,version);
params.Main.Dwell_time__us_ = readprairie3keyvalue(fid,'dwellTime',meatind(1),500,version);
params.Main.Frame_period__us_ = 1e6*readprairie3keyvalue(fid,'framePeriod',meatind(1),500,version);
params.Main.Lines_per_frame = readprairie3keyvalue(fid,'linesPerFrame',meatind(1),500,version);
params.Main.Pixels_per_line = readprairie3keyvalue(fid,'pixelsPerLine',meatind(1),500,version);
params.Main.ObjectiveLens = readprairie3keyvalue(fid,'objectiveLens',meatind(1),500,version);
params.Main.ObjectiveLensMag = readprairie3keyvalue(fid,'objectiveLensMag',meatind(1),500,version);
params.Image_TimeStamp__us_ = imagetimes;

if isempty(params.Main.Dwell_time__us_),
	% try the config file
	[pathstr,fname,extension] = fileparts(filename);
	dotcfgfile = fullfile(pathstr,[fname 'Config.cfg']);
	fid2 = fopen(dotcfgfile);
	if fid2<0,
		error(['Could not find parameter dwellTime in either ' filename ' or ' dotcfgfile ...
			'; is this a new version of PV?; tell steve to upgrade.']);
	else,
		params.Main.Scanline_period__us_ = 1e6*readprairie3keyvalue(fid2,'scanlinePeriod',1,500,version);
		params.Main.Dwell_time__us_ = readprairie3keyvalue(fid2,'dwellTime',1,500,version);
		params.Main.Frame_period__us_ = 1e6*readprairie3keyvalue(fid2,'framePeriod',1,500,version);
		params.Main.Lines_per_frame = readprairie3keyvalue(fid2,'linesPerFrame',1,500,version);
		params.Main.Pixels_per_line = readprairie3keyvalue(fid2,'pixelsPerLine',1,500,version);
		params.Main.ObjectiveLens = readprairie3keyvalue(fid2,'objectiveLens',1,500,version);
		params.Main.ObjectiveLensMag = readprairie3keyvalue(fid2,'objectiveLensMag',1,500,version);
		fclose(fid2);
	end;
end;

for i=1:length(imagespercycle),
	eval(['params.Cycle_' int2str(i) '.Number_of_images=imagespercycle(i);']);
end;

if length(lscycind)>0, % if we have a linescan...
	% extract line scan parameters

	% first, Line definition, assume same line definition
	pos = lscycind(1,1);
	params.Linescanpoints = readlinescandefinition(fid,pos);
	
    [pathstr,name,ext] = fileparts(filename);
    fid1 = fopen(fullfile(pathstr,[name 'Config.cfg']));
    if fid1<0,
        error(['Could not locate config file:' fullfile(pathstr,[name 'Config.cfg'])]);
    else,
        params.Main.fullImageLinesPerFrame = readprairie3keyvalue(fid1,'fullImageLinesPerFrame',0,1000,version);
        params.Main.fullImagePixelsPerLine = readprairie3keyvalue(fid1,'fullImagePixelsPerLine',0,1000,version);
        fclose(fid1);
    end;
end;

fclose(fid);

function str = readprairie3keyvalue(fid,keyname,pos,howmanylinestolook,version)
fseek(fid,pos,'bof');
str = '';
done = 0;
i = 0;
while ~done&i<howmanylinestolook,
	q = fgetl(fid);
	inds = find(q~=' '); q = q(inds(1):end);
    A = any(strfind(lower(q),lower(['<Key key="' keyname '"']))); 
    B = any(strfind(lower(q),lower(['<PVStateValue key="' keyname '"'])));
    if A|B,
		myind = findstr(q,'value="');
		myq = find(q=='"');
		myq = myq(find(myq>myind+7));
		if ~isempty(myind)&~isempty(myq),
			str = q(myind+7:myq-1);
			done = 1;
		end;
	end;
	i = i + 1;
end;

if ~isempty(str),
	try,
		str = eval(str);
	end;
end;


function [pts] = readlinescandefinition(fid,pos)

pts = [];

fseek(fid,pos,'bof');
q = 0;
while q~=-1,
	q = fgetl(fid);
        if any(strfind(q,'PVLinescanDefinition mode="freeHand"')),
		% we know freehand
		inds = find(q~=' '); q = q(inds(1):end);
		pts = []; done = 0;
		while ~done,
			newline = fgetl(fid);
			inds = find(newline~=' '); newline = newline(inds(1):end);
			newpts = sscanf(newline,'<Freehand x="%f" y="%f" z="%f" />');
			if length(newpts)>=2, pts = cat(1,pts,newpts');
			else, done = 1;
			end;
		end;
        elseif any(strfind(q,'PVLineScanDefinition mode="')),
		error(['Do not know this LineScanDefinition mode, only know freehand. Extend me please!']);
        end;
end;

function [imagetimes, imagespercycle, tscycind, lscycind, meatind] = GetFrameTimes(fid,pos,version)

imagetimes = [];
imagespercycle = [];
tscycind = [];
lscycind = [];
meatind = [];
currentcycle = 0;
cyclenum = 0;

if version(1)==3 | version(1)==4,
    tseries_str = '<Sequence type="TSeries Timed Element';
elseif version(1)==5&version(2)==5,
    tseries_str = '<Sequence type="TSeries Timed Element';
elseif version(1)==5,
    tseries_str = '<Sequence type="TSeries Brightness Over Time Element';
else,
    error(['Do not know how to read files from PVScan version ' int2str(version(1)) '.']);
end;


fseek(fid,pos,'bof');

q = 0;
while q~=-1,
    q = fgetl(fid);
	inds = find(q~=' '); q = q(inds(1):end);
    if any(strfind(q,tseries_str)),
        tscycind(length(tscycind)+1) = ftell(fid);
        cyclenum = sscanf(q,[tseries_str '" cycle="%d">']);
    elseif any(strfind(q,'<Sequence type="Single"')),
        % we will consider Single images 1-image TSeries b/c PrairieView
        % essentially treats them as such
        tscycind(length(tscycind)+1) = ftell(fid);
        cyclenum = 1;  % PV says cycle is "0", but it lies, filename says 1
    elseif any(strfind(q,'<Sequence type="Linescan"')),
		lscycind(length(lscycind)+1) = ftell(fid);
		cyclenum = cyclenum + 1; % apparent PrairieView bug; every cycle labeled as "1"
    elseif any(strfind(q,'<Frame relativeTime')),
        [output]=sscanf(q,'<Frame relativeTime="%f" absoluteTime="%f" index="%d" label="%s">');
        imagespercycle(currentcycle) = imagespercycle(currentcycle)+1;
        imagetimes(end+1) = output(2) * 1e6; % convert to us
        if length(meatind)<cyclenum, meatind(end+1) = ftell(fid); end;
	end;
	if currentcycle~=cyclenum,
        currentcycle = cyclenum;
        imagespercycle(currentcycle) = 0;
	end;
end;

