function fname=tpfilename(tpfileparams,cycle,channel,frame)

error('this must be re-done for FluoView');

fname=[tpfileparams.fnameprefix '_Cycle' sprintf('%.3d',cycle) '_' tpfileparams.myconfigstr 'Ch' int2str(channel) '_' sprintf('%.6d',frame)  tpfileparams.extension];
