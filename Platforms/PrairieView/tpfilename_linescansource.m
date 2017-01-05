function fname=tpfilename_linescansource(tpfileparams,cycle,channel,frame)

if isfield(tpfileparams,'digits'),
    D = tpfileparams.digits;
else
    D = 3;
end;

fname=[tpfileparams.fnameprefix '-Cycle' sprintf(['%.' int2str(D) 'd'],cycle) '_'  'Ch' int2str(channel) 'Source' tpfileparams.extension];
