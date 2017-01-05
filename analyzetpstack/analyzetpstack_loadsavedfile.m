function mydata = analyzetpstack_loadsavedfile(ds,stackname,dirname)

% ANALYZETPSTACK_LOADSAVEDFILE - Load a saved tuning curve file
%
%  MYDATA = ANALYZETPSTACK_LOADSAVEDFILE(DS,STACKNAME,DIRNAME)
%
%  will attempt to load saved tuning curve data from the experiment data
%  that is being read by a DIRSTRUCT object DS, with ANALYZETPSTACK name
%  STACKNAME (e.g., 'Site1'), and test directory DIRNAME (e.g., 't00001').
%  
%  (This function will first look for a data file in the old version location
%  before looking in the new version location.)
%
%  See also:  ANALYZETPSTACK, ANALYZETPSTACK_GETSAVEDFILE

fname = analyzetpstack_getsavedfilename(ds,stackname,dirname);

if exist(fname)==2,
	mydata = load(fname);
else, % try the old filename
	fnameold = analyzetpstack_getoldsavedfilename(ds,stackname,dirname);
	if exist(fnameold),
		mydata = load(fname,'-mat');
	else, % let this function produce the error
		mydata = load(fname);
	end;
end;

