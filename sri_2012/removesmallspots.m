function [newmask, goodinds] = removesmallspots(labeledmask, minsize)

% REMOVESMALLSPOTS - Remove small spots from a labeled mask
%
%  [NEWMASK, GOODINDS] = REMOVESMALLSPOTS(LABLEDMASK, MINSIZE)
%
%  Removes discrete pixel blobs that are smaller than MINSIZE. The input
%  MASK should be labeled, such as with BWLABEL.  The modified mask is
%  returned in NEWMASK, and the index values of the labeled blobs that
%  are bigger than MINSIZE are returned in GOODINDS.
%

newmask = labeledmask;
goodinds = [];

for ii=1:max(labeledmask(:)),
	blobinds = find(labeledmask==ii);
	if length(blobinds)<minsize,
		newmask(blobinds) = 0;
	else,
		goodinds(end+1) = ii;
	end;
end;
