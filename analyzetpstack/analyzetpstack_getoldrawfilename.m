function fn = analyzetpstack_getoldrawfilename(ds,stackname,dirname)
  % returns old raw file name
scratchname = fixpath(getscratchdirectory(ds,1));
fn = [scratchname stackname '_' dirname '_raw.mat'];


