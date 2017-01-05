function kristen2vhlab(source, destination, prefix_str__, ref__)

% KRISTEN2VHLAB - Convert from Kristen Ade's style to VHLAB style
%
%   KRISTEN2VHLAB(SOURCE, DESTINATION)
%
%   SOURCE and DESTINATION should have full paths
%
%   Example:
%
%    kristen2vhlab('C:\mydataorig\2012-05-20','C:\myvhdata\2012-05-20')
%
%   

if nargin<3, prefix_str__ = []; end;
if nargin<4, ref__ = -1; end;

%[source ':' destination ':' prefix_str__ ':' int2str(ref__) ';'],

if nargin==2 & exist(destination)==7, error(['Destination directory ' destination ' already exists.']); end;

if nargin<3, prefix_str = ''; else, prefix_str = prefix_str__;  end;
if nargin<4, ref = 0; else, ref = ref__; end;

nameref.name = 'tp';
nameref.ref = ref;
nameref.type = 'prairietp';

d = dir(source);

for i=1:length(d),
	k = findstr(d(i).name,'-');
	candidate_2p_data_dir = 0;
	if ~isempty(k),
		if (length(d(i).name)==(k(end)+3)  |  length(d(i).name)==(k(end)+4)) &d(i).isdir,
			candidate_2p_data_dir = 1;
		end;
	end;
	if length(prefix_str)==0& (~isempty(findstr(lower(d(i).name),'slice'))&d(i).isdir),
		nameref.ref = nameref.ref + 1;
		newdirname = d(i).name(find(~isspace(d(i).name)));
		k = findstr(lower(newdirname),'slice');
		newdirname = newdirname([k k+5:end]);

		disp(['Detected slice directory ' d(i).name '...proceeding using reference ' int2str(nameref.ref) ' and prefix ' newdirname '.']);
		kristen2vhlab([source filesep d(i).name],destination,newdirname,nameref.ref);
	elseif length(prefix_str)>0&candidate_2p_data_dir,

		disp(['***Processing directory ' [source filesep d(i).name] ' as a 2-photon directory.']);
		
		newtpname = d(i).name;

		% shorten names, remove 'in', spaces

		k = findstr(lower(newtpname),'single');
		if ~isempty(k), newtpname = [newtpname(1:k-1) 's' newtpname(k+6:end)]; end;
		k = findstr(lower(newtpname),'paired');
		if ~isempty(k), newtpname = [newtpname(1:k-1) 'p' newtpname(k+6:end)]; end;
		k = findstr(lower(newtpname),' in ');
		if ~isempty(k), newtpname = [newtpname(1:k-1) newtpname(k+4:end)]; end;
		k = findstr(lower(newtpname),'stim');
		if ~isempty(k), newtpname = [newtpname(1:k-1) newtpname(k+4:end)]; end;
		k = find(~isspace(newtpname));
		newtpname = newtpname(k);
		newtpname(find(newtpname(k)=='.')) = 'o';

		k = findstr(newtpname,'-');
		newtpname = newtpname(1:k-1);
		newtpname = [prefix_str '_' newtpname];

		% now, check for an already existing directory

		if exist([destination filesep newtpname])==7, newtpname = [newtpname 'a']; end;
		while exist([destination filesep newtpname])==7,
			newtpname(end) = char( double(newtpname(end))+1 );
		end;

		% now we have a unique destination name

		mkdir([destination filesep newtpname]);
		saveStructArray([destination filesep newtpname filesep 'reference.txt'],nameref,1);
		
		copyfile([source filesep d(i).name],[destination filesep newtpname '-001']);

	elseif length(prefix_str)&d(i).isdir&~strcmp(d(i).name,'.')&~strcmp(d(i).name,'..'), % subdirectory
		newtpname = d(i).name;

		% shorten names, remove 'in', spaces

		k = findstr(lower(newtpname),'single');
		if ~isempty(k), newtpname = [newtpname(1:k-1) 's' newtpname(k+6:end)]; end;
		k = findstr(lower(newtpname),'paired');
		if ~isempty(k), newtpname = [newtpname(1:k-1) 'p' newtpname(k+6:end)]; end;
		k = findstr(lower(newtpname),' in ');
		if ~isempty(k), newtpname = [newtpname(1:k-1) newtpname(k+4:end)]; end;
		k = findstr(lower(newtpname),'stim');
		if ~isempty(k), newtpname = [newtpname(1:k-1) newtpname(k+4:end)]; end;
		k = find(~isspace(newtpname));
		newtpname(find(newtpname(k)=='.')) = 'o';
		newtpname = newtpname(k);
		
		prefix_str_new = [prefix_str '_' newtpname];
		disp(['***Traversing subdirectory ' source filesep d(i).name ' using prefix ' prefix_str_new '.']);
		kristen2vhlab([source filesep d(i).name],destination,prefix_str_new,nameref.ref);
	elseif ~(strcmp(d(i).name,'.')|strcmp(d(i).name,'..')), % ignore
		disp(['Did not recognize ' d(i).name ' as a slice or data directory, ignoring it.']);
	end;
end;


