function tpfileparams=tpfnameparams(dirname,channel, params)

tpfileparams.extension = '.tif';
fname = dir([dirname filesep '*_t*1.tif']);
if isempty(fname),
    tpfileparams.extension = '.TIFF';
	fname = dir([dirname filesep '*_t*1.TIFF']);
	if isempty(fname),
        tpfileparams.extension = '.tiff';
		fname = dir([dirname filesep '*_t*1.tiff']);
		if isempty(fname),
            tpfileparams.extension = '.TIF';
			fname = dir([dirname filesep '*_t*1.TIF']);
		end;
	end;
end;

strind = findstr(fname(end).name,'_t');

tpfnameparams.fnameprefix = fname(end).name(1:strind(end)-1);
