function shiftdriftcorrect(dirname, x, y)

% SHIFTDRIFTCORRECT - manually move the drift correct results
%
% SHIFTDRIFTCORRECT(DIRNAME, Xshift, Yshift)
%
%   Perform a manual shift of the drift correct results for a
%   two-photon directory.
%  Example:
%
%     SHIFTDRIFTCORRECT('e:\myexper\mydir-001',0,0)
%
%       makes no shift.

d = load([dirname filesep 'driftcorrect'],'-mat');

drift = d.drift;

drift = drift + repmat([x y],size(drift,1),1);

save([dirname filesep 'driftcorrect'],'drift','-append','-mat');
