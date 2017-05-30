function tpfileparams=tpfnameparams(dirname,channel)

fname = dir([dirname filesep '*.lsm']);
if isempty(fname),
    error(['Cannot find any .lsm files here.']);
end;

strind = findstr(fname(end).name,'.lsm');

tpfileparams.fnameprefix = fname(end).name(1:strind(end)-1);
tpfileparams.extension = '.lsm';
