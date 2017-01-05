function tpfileparams =tpfnameparams(dirname,channel,params)

% TPFNAMEPARAMS - Returns any parameters that might be needed to create filenames
%
%  TPFILEPARAMS = TPFNAMEPARAMS(DIRNAME,CHANNEL,PARAMS)%
%
%    Examines the directory DIRNAME and returns any information that would be
%    required for the program to open the file for frame N.
%    CHANNEL is the channel to be analyzed, PARAMS is the parameters extracted from the
%    file.

extension = '.tif';
fname = dir([dirname filesep '*.tif*']);
tpfileparams.filenames = fname;

