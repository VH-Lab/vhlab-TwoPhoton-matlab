function sandrine2vhlabtstack(source, destination)

% SANDRINE2VHLAB - Convert from Sandrine's format to VHLAB-style tiff stacks
%
%   SANDRINE2VHLAB(SOURCEFILE, DESTINATION)
%
%   SOURCEFILE and DESTINATION should have full paths
%
%   Example:
%
%    sandrine2vhlabtstack('C:\mydataorig\myfile.lif','C:\myvhdata\2012-05-20')
%
%

disp(['Reading file ' source '...']);
[x,xmlfile] = bioformats2xml(source);

disp(['Reading XML file ' xmlfile '...may take a few minutes...']);
s = xml2struct(xmlfile); 

ch = s.Children;

imageNames = {};

frame_dT = {};
frame_T = {};

for i=1:numel(ch),
	if strcmp(ch(i).Name,'Image'),
		for j=1:numel(ch(i).Attributes),
			if strcmp(ch(i).Attributes(j).Name,'Name')
				imageNames{end+1} = ch(i).Attributes(j).Value;
			end
		end
		for j=1:numel(ch(i).Children),
			if strcmp(ch(i).Children(j).Name,'Pixels'),
				frame_dt_here = [];
				frame_T_here = [];
				for k=1:numel(ch(i).Children(j).Children),
					if strcmp(ch(i).Children(j).Children(k).Name,'Plane'),
						for l = 1:numel(ch(i).Children(j).Children(k).Attributes),
							if strcmp(ch(i).Children(j).Children(k).Attributes(l).Name,'DeltaT'),
								frame_dt_here(end+1) = eval(ch(i).Children(j).Children(k).Attributes(l).Value);
							end
							if strcmp(ch(i).Children(j).Children(k).Attributes(l).Name,'TheT'),
								frame_T_here(end+1) = eval(ch(i).Children(j).Children(k).Attributes(l).Value);
							end
						end
					end
				end;
				frame_dT{end+1} = unique(frame_dt_here);
				frame_T{end+1} = unique(frame_T_here);
			end
		end
	end
end

r = bfGetReader(source);

disp(['Number of image names retrieved: ' int2str(numel(imageNames)) ', seriesCount ' int2str(r.getSeriesCount()) '.' ])
disp([cell2str(imageNames)])

log = [ ]; % [DG/CA3 1/3 , control/inhib 1/2]

logcount = [];

useit = [];

ref = 1;

channel = 1;

try, mkdir(destination); end;

for i=1:r.getSeriesCount(),

	dgca3var = 0;
	controlinhibvar = 0;

	if ~isempty(strfind(lower(imageNames{i}),'dg')),
		dgca3var = 1;
	end;
	if ~isempty(strfind(lower(imageNames{i}),'ca3')),
		dgca3var = 3;
	end;
	if ~isempty(strfind(lower(imageNames{i}),'cn')),
		controlinhibvar = 1;
	end;
	if ~isempty(strfind(lower(imageNames{i}),'inhib')),
		controlinhibvar = 2;
	end;

	log = [log; dgca3var controlinhibvar];

	logcount(end+1) = sum( double(log(:,1)==dgca3var & log(:,2)==controlinhibvar) );

	if logcount(end)>1, % must be prior entries
		useit(find(  log(:,1)==dgca3var & log(:,2)==controlinhibvar )) = 0;
	end

	useit(i) = 1;
end;

for i=1:r.getSeriesCount(),

	r.setSeries(i-1);

	if useit(i),
		dgca3var = log(i,1);
		controlinhibvar = log(i,2);

		namestr = 'generic';
		if dgca3var==1,
			namestr = 'dg_';
		elseif dgca3var==3,
			namestr = 'ca3_';
		end;

		if controlinhibvar==1,
			namestr = [namestr 'control'];
		elseif controlinhibvar==2,
			namestr = [namestr 'inhib'];
		end

		nameref.name = 'tp';
		nameref.ref = ref;
		nameref.type = 'prairietp';

		testdir= ['t' int2str(dgca3var) int2str(controlinhibvar) sprintf('%.3d',1) ];

		disp(['Making testdir ' testdir ' with filename ' namestr '.tif...']);

		try, mkdir([destination filesep testdir]); end;

		saveStructArray([destination filesep testdir filesep 'reference.txt'],nameref);

		% now do export of TIFs, assume T series

		c = r.getSizeC();
		z = r.getSizeZ();
		t = r.getSizeT();

		if z>1, error(['Do not know what to do with z size greater than 1.']); end;

		for t_ = 1:t,
			iPlane = r.getIndex(0,channel-1,t_-1) + 1;
			I = bfGetPlane(r,iPlane);
			if t_==1,
				imwrite(I,[destination filesep testdir filesep namestr '.tif']);
			else,
				imwrite(I,[destination filesep testdir filesep namestr '.tif'],'writemode','append');
			end
		end

		p = struct('parameter','FrameRate','value',1/median(diff(frame_dT{i})),'desc','The frame rate in Hz');
		saveStructArray([destination filesep testdir filesep 'params.tiffstack'], p);
			
		ref = ref+1;
	end
end

