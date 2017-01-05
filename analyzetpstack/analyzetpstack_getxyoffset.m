function xyoffset = analyzetpstack_getxyoffset(ud,dirname)
% Return the X/Y offset of a slice relative to the stack as a whole
%
%   [X Y] = ANALYZETPSTACK_GETXYOFFSET(UD, DIRNAME)
%
%  Where UD is USERDATA for analyzetpstack window and
%  DIRNAME is the directory name to examine.

myparent = analyzetpstack_getrefdirname(ud,dirname);
xyoffset = [0 0];
for j=1:length(ud.slicelist),
    if strcmp(myparent,trimws(ud.slicelist(j).dirname)),
        xyoffset = ud.slicelist(j).xyoffset;
    end;
end;

