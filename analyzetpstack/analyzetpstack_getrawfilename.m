function fn = analyzetpstack_getrawfilename(ds,stackname,dirname)
% ANALYZESTPACK_GETRAWFILENAME - Returns the filename of the raw F analysis
%
%  FN = ANALYZETPSTACK_GETRAWFILENAME(DS,STACKNAME,DIRNAME)
%
%   Where DS is a DIRSTRUCT for the experiment directory, STACKNAME is the
%   ANALYZETPSTACK stack name, and DIRNAME is the directory (e.g., 't00001').

fulldirname = [fixpath(getpathname(ds)) dirname];
fn = [fulldirname filesep stackname '_' dirname '_raw.mat'];

