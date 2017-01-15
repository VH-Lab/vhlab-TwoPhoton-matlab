function celllist = spots2celllist(labeledmask, dirname, initialindex, label, type, contour)

% SPOTS2CELLLIST - Convert a labeled spot list to analyzetpstack cells
%
%  CELLLIST=SPOTS2CELLIST(LABELEDMASK, DIRNAME, INITIALINDEX, LABELS, TYPE, CONTOUR)
%
%  Creates an ANALYZETPSTACK cell list.

labels = setdiff(unique(labeledmask(:)),0);

celllist = [];

for i=1:length(labels),
	newcell = analyzetpstack_emptycellrec;
	newcell.dirname = dirname;
	newcell.labels = {label};
	newcell.type = type;
	newcell.pixelinds = find(labeledmask==labels(i));
	newcell.xi = contour{i}(:,2);
	newcell.yi = contour{i}(:,1);
	newcell.index = initialindex + i;
	if isempty(celllist),
		celllist=newcell;
	else,
		celllist(end+1)=newcell;
	end;
end;

