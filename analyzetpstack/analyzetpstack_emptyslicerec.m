function sr = analyzetpstack_emptyslicerec

% ANALYZETPSTACK_EMPTYSLICEREC - Empty slice record structure for analyzetpstack
%
%  EMPTYSLICE = ANALYZETPSTACK_EMPTYSLICEREC
%
%   The slice structure EMPTYSLICE has fields
%        dirname           :         the name of the directory
%        depth             :         a number indicating the recording depth
%        drawcells         :         should cells be drawn in the display?
%        analyzecells      :         should linescans be drawn?
%        xyoffset          :         any x,y offset for this slice
%

sr = struct('dirname','','depth',0,'drawcells',1,'analyzecells',1,'xyoffset',[0 0]);

