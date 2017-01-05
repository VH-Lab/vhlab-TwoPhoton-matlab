function fname=tpfilename(tpfileparams,cycle,channel,frame)

if isfield(tpfileparams,'digits'),
    D = tpfileparams.digits;
else, 
    D = 3;
end;

fname=[tpfileparams.fnameprefix '_Cycle' sprintf(['%0.' int2str(D) 'd'],cycle) '_' tpfileparams.myconfigstr 'Ch' int2str(channel) '_' sprintf('%.6d',frame)  tpfileparams.extension];
