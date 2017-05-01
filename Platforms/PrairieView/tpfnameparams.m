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
fname = dir([dirname filesep '*_Cycle001*Ch' int2str(channel) '*1.tif']);
digits = 3;
if isempty(fname),
    extension = '.tif';
    fname = dir([dirname filesep '*_Cycle00001*Ch' int2str(channel) '*1.tif']);
    digits = 5;
    if isempty(fname),
        digits = 3;
    	extension = '.TIFF';
    	fname = dir([dirname filesep '*_0*1.TIFF']);
    	if isempty(fname),
    		extension = '.tiff';
    		fname = dir([dirname filesep '*_0*1.tiff']);
    		if isempty(fname),
    			extension = '.TIF';
    			fname = dir([dirname filesep '*_0*1.TIF']);
    		end;
    	end;
    end;
end;

strind = findstr(fname(end).name,'_Cycle');

fnameprefix = fname(end).name(1:strind(end)-1);
tpfileparams.fnameprefix = fnameprefix;
tpfileparams.extension = extension;
tpfileparams.digits = digits;

 % pick out v3 file format

myconfigstr = sscanf(fname(end).name,[fnameprefix '_Cycle' sprintf(['%0.' int2str(digits) 'd'],1) '_%sCh' int2str(channel) '_000001.' extension]);

if ~isempty(myconfigstr),
	lastind = findstr(myconfigstr,['_Ch' int2str(channel)]);
	myconfigstr = myconfigstr(1:lastind);
end;

tpfileparams.myconfigstr = myconfigstr;


