function fname = tpconfigfilename(dirname)
% TPCONFIGFILENAME - Name of the PrairieView configuration file
%
%  FNAME = TPCONFIGFILENAME(TPDIRNAME)
%   OR
%  FNAME = TPCONFIGFILENAME(TPCONFIGFILE)
%
%  If TPDIRNAME is a directory, then READPRAIRIECONFIG determines
%  the name of the config file.  If TPCONFIGFILE is a file, then 
%  READPRARIECONFIG will check to make sure it is actually the 
%  correct file to be opening.
%
%  See also: READPRAIRIECONFIG 

if exist(dirname)==7,
    tpdirname = dirname;
else,
    [tpdirname,filename] = fileparts(dirname);
	if isempty(tpdirname), tpdirname = pwd; end;
end;

pcfile = dir([tpdirname filesep '*_Main.pcf']);
if isempty(pcfile),
    pcfile = dir([tpdirname filesep '*.xml']);
    include = [];
    for i=1:length(pcfile),
        if strcmp(upper(pcfile(i).name),upper('tour.xml')), 
        elseif strcmp(upper(pcfile(i).name),upper('exlude.xml')),
        else,
            include(end+1) = i;
        end;
    end;
    if isempty(include),
        error(['Could not find config file for ' dirname '.']);
    end;
    pcfile = pcfile(include(end)).name;
else,
    pcfile = pcfile(end).name;
end;

fname = fullfile(tpdirname, pcfile);