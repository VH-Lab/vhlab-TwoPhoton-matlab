function [dr_initial, dr_all_raw, dr_all_offset] = analyzetpstack_getdirdrift(ud, dirname, numpreviewframes)
% ANALYZETPSTACK_GETDIRDRIFT - Get drift correction information from a directory
%
%  [DR_INITIAL, DR_ALL_RAW, DR_ALL_OFFSET] = ANALYZETPSTACK_GETDIRDRIFT(UD, DIRNAME, NUMPREVIEWFRAMES)
%
%  Given current userdata UD from an active ANALYZETPSTACK window, and
%  the name of an associated directory DIRNAME (local path), and the 
%  number of frames to assume in the preview image (NUMPREVIEWFRAMES, 
%  1 if not given), this function returns:
%
%  DR_INITIAL = [driftx drifty], the x-y drift of the 'preview' image of the
%     directory, and
%  DR_ALL_RAW = [driftx(:) drifty(:)], the raw x-y drift of each individual frame
%     and 
%  DR_ALL_CORRECTED = [driftx(:) drifty(:)], the x-y drift of each individual frame plus 
%     any XY offset that is provided for DIRNAME in the ANALYZETPSTACK window.
%   

if nargin<3,
	numpreviewframes = 1;
end;

tpdirs = tpdirnames([getpathname(ud.ds) dirname]);
if isempty(tpdirs),
	warning(['No driftcorrect file for ' dirname '; shift information will change after drift correction.']);
	dr_initial = [0 0];
	dr_all_raw = [0 0];
else,
	if exist([tpdirs{1} filesep 'driftcorrect'])~=2,
		warning(['No driftcorrect file for ' dirname '; shift information will change after drift correction.']);
		dr_initial = [0 0];
		dr_all_raw = [0 0];
	else,
		d=load([tpdirs{1} filesep 'driftcorrect'],'-mat');
		dr_all_raw = d.drift;
		try,
			dr_initial = mean(d.drift(1:numpreviewframes,:),1); % just get the initial drift
		catch,
			dr_initial = d.drift(1,:);
		end;
	end;
end;

% now add XY offset to drift
xyoffset = analyzetpstack_getxyoffset(ud,dirname);
dr_initial = dr_initial + xyoffset;
dr_all_offset = dr_all_raw + repmat(xyoffset, size(dr_all_raw,1), 1);

