function fn = analyzetpstack_getoldsavedfilename(ds,stackname,dirname)
  % returns the old saved filename
scratchname = fixpath(getscratchdirectory(ds,1));
fn = [scratchname stackname '_' dirname ];


