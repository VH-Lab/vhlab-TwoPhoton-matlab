function [slicestructupdate] = analyzetpstack_updatecelldraw(ud,i,slicestruct,currdir,numpreviewframes)
% ANALYZETPSTACK_UPDATECELLDRAW - construct a lookup table for slicelist, drift, and ancestors, if it doesn't already exist
if isempty(slicestruct),
	slicestruct.slicelistlookup.test = [];
	slicestruct.slicedriftlookup.test = [];
	slicestruct.slicexyoffsetlookup.test = [];
	slicestruct.sliceancestorlookup.test = [];
	for j=1:length(ud.slicelist),
		cleandirname = trimws(ud.slicelist(j).dirname); % remove any leading spaces if indented
		slicestruct.slicelistlookup=setfield(slicestruct.slicelistlookup,cleandirname,j);
		slicestruct.slicedriftlookup=setfield(slicestruct.slicedriftlookup,cleandirname,...
			analyzetpstack_getdirdrift(ud,cleandirname));
		slicestruct.slicexyoffsetlookup = setfield(slicestruct.slicexyoffsetlookup, cleandirname, ...
			analyzetpstack_getxyoffset(ud,cleandirname));
		slicestruct.sliceancestorlookup=setfield(slicestruct.sliceancestorlookup,cleandirname, analyzetpstack_getallparents(ud,cleandirname));
	end;
end;
slicestructupdate = slicestruct;

% must draw cell if it exists in current image or if
%   its parent 'drawcells' field is checked.
ancestors = getfield(slicestructupdate.sliceancestorlookup,currdir);
cellisinthisimage = ~isempty(intersect(ud.celllist(i).dirname,ancestors));
drawcellsinthisimage = getfield(ud.slicelist(getfield(slicestructupdate.slicelistlookup,currdir)),'drawcells');
thiscellsparentdrawcells = getfield(ud.slicelist(getfield(slicestructupdate.slicelistlookup,ud.celllist(i).dirname)),'drawcells');
if (cellisinthisimage && drawcellsinthisimage) || (~cellisinthisimage && thiscellsparentdrawcells),
    % show cell
    set(ud.celldrawinfo.h(i),'visible','on');
    set(ud.celldrawinfo.t(i),'visible','on');
else % hide it
    set(ud.celldrawinfo.h(i),'visible','off');
    set(ud.celldrawinfo.t(i),'visible','off');
end;
% now draw cell with appropriate position and color
if cellisinthisimage,
	drift = getfield(slicestructupdate.slicedriftlookup, currdir);
	xyoffset = getfield(slicestructupdate.slicexyoffsetlookup, currdir);
	total_drift = drift + xyoffset;
	changes = analyzetpstack_getChanges(ud,i,currdir,ancestors);
	if changes.present,
		mycolor = [0 0 1];
	else,
		mycolor = [ 1 0.5 0.5];
	end;
else
	drift = getfield(slicestructupdate.slicedriftlookup, ud.celllist(i).dirname);
	xyoffset = getfield(slicestructupdate.slicexyoffsetlookup, ud.celllist(i).dirname);
	total_drift = drift + xyoffset;
	changes = analyzetpstack_getChanges(ud,i,ud.celllist(i).dirname,[]);
	mycolor = [1 0 0];
end;
set(ud.celldrawinfo.h(i),'color',mycolor);
set(ud.celldrawinfo.t(i),'color',mycolor);
xi = changes.xi;
xi(end+1) = xi(1);
yi = changes.yi;
yi(end+1) = yi(1);
set(ud.celldrawinfo.h(i),'xdata',xi-total_drift(1),'ydata',yi-total_drift(2));
set(ud.celldrawinfo.t(i),'position',[mean(xi)-total_drift(1) mean(yi)-total_drift(2) 0]);

