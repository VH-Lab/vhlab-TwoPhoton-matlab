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
%   The converter examines the file 'sandrine_codes.tsv', a tab-separated-value file
%   with fields "searchstring", "namestring", and "value. "searchstring" indicates the 
%   string that is searched for in the image name; if a match is found, then the corresponding
%   namestring is added to the tiff file name of the converted file, and the value is added to the
%   test directory name.
%
%   Example:
%   searchstring     | namestring    | value | 
%   ------------------------------------------
%   ca3              | ca3_          | 30000 |
%
%   If the string 'ca3' is found in the ImageName property of myfile.lif, then the converted TIF file name
%   will begin with 'ca3_' and the test folder number will be incremented by 30000.
%
%
%   See also: type sandrine_codes.tsv

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


output_dirvalues = {};
output_dirnames = {};
output_filenames = {};
parentdir = fileparts(which('sandrine2vhlabtstack'));
instructions = loadStructArray([parentdir filesep 'sandrine_codes.tsv']);

log = [ ]; % [DG/CA3 1/3 , control/inhib 1/2]

logcount = [];

useit = [];

ref = 1;

channel = 1;

try, mkdir(destination); end;

for i=1:r.getSeriesCount(),

	output_dirvalues{i} = 0;
	output_filenames{i} = '';

	for j=1:numel(instructions),
		if ~isempty(strfind(lower(imageNames{i}),lower(instructions(j).searchstring))),
			output_filenames{i} = [output_filenames{i} instructions(j).namestring];
			output_dirvalues{i} = output_dirvalues{i} + instructions(j).value;
		end
	end;

	output_dirnames{i} = ['t' sprintf('%.5d',output_dirvalues{i})];

	indexes = find(strcmp(output_dirnames{i},output_dirnames));
	indexes = indexes(find(indexes<i));
	useit(indexes) = 0;

	useit(i) = 1;

end;

for i=1:r.getSeriesCount(),

	r.setSeries(i-1);

	if useit(i),
		nameref.name = 'tp';
		nameref.ref = ref;
		nameref.type = 'prairietp';

		testdir = output_dirnames{i};
		namestr = output_filenames{i};

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

