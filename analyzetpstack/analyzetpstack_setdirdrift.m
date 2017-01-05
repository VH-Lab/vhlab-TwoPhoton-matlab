function analyzetpstack_setdirdrift(ud, dirname, driftvalues)
% ANALYZETPSTACK_SETDIRDRIFT - Set drift correction information for a directory
%
%  ANALYZETPSTACK_SETDIRDRIFT(UD, DIRNAME, DRIFTVALUES)
%
%  Given current userdata UD from an active ANALYZETPSTACK window, and
%  the name of an associated directory DIRNAME (local path), and the 
%  drift values ( x - y pairs, one entry per frame), this function writes the 
%  'driftcorrect' .mat file (without extension, for historical reasons) in the
%  first directory with two-photon data that is associated with DIRNAME.
%

tpdirs = tpdirnames([getpathname(ud.ds) dirname]);
if isempty(tpdirs),
	error(['No two-photon data for ' dirname '.']); 
else,
	drift = driftvalues;
	save([tpdirs{1} filesep 'driftcorrect'],'drift','-mat');
end;

