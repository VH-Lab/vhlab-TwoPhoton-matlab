function fn = analyzetpstack_getsavedfilename(ds,stackname,dirname)
% ANALYZESTPACK_GETSAVEDFILENAME - Returns the filename of the saved F analysis
%
%  FN = ANALYZETPSTACK_GETSAVEDFILENAME(DS,STACKNAME,DIRNAME)
%
%   Where DS is a DIRSTRUCT for the experiment directory, STACKNAME is the
%   ANALYZETPSTACK stack name, and DIRNAME is the directory (e.g., 't00001').

fulldirname = [fixpath(getpathname(ds)) dirname];
fn = [fulldirname filesep stackname '_' dirname '.mat'];

