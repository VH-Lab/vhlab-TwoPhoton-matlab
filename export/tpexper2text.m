function tpexper2text(expername)

% TPEXPER2TEXT - Convert raw output of 2-photon experiment to text
%
%   TPEXPER2TEXT(EXPERNAME)
%
%  Convert all analzed raw data to text format, where EXPERNAME is the
%  name of the experiment directory to be converted.
%
%  The data must first have been analyzed with analyzetpstack; the new files
%  are stored in each test directory (e.g., data from directory t00001 will
%  be stored in t00001; this is regardless of where the 2-photon data may
%  be stored (with Prairie, for example, this is usually t00001-001)).
%
%  To see how the text files will be arranged in the file, please see 
%  'help tpraw2text'
%
%  Example:
%     tpexper2text('C:\mydata\2011-05-24\');
%
%  See also: ANALYZETPSTACK

ds = dirstruct(expername);

T = getalltests(ds);

for t=1:length(T),
	disp(['Attempting to convert subdirectory ' T{t} '.']);
	try,
		d = dir([getpathname(ds) filesep T{t} filesep '*_raw.mat']);
		for i=1:length(d),
			tpraw2text([getpathname(ds) filesep T{t} filesep d(i).name]);
		end;
		if ~isempty(d),
			disp(['Converted subdirectory ' T{t} '.']);
		else, 
			disp(['...no data to convert in subdirectory ' T{t} '.']);
		end;
	catch,
		disp(upper(['****Error converting subdirectory ' T{t} '.']));
	end;
end;
