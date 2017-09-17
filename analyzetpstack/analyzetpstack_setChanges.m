function analyzetpstack_setChanges(ud,fig,i,newchanges)
% ANALYZETPSTACK_SETCHANGES - add a change to a cell's parameters, such as movement, not present, etc
%
%  Note: sets userdata of 'fig'
if ~isfield(ud.celldrawinfo,'changes'), ud.celldrawinfo.changes = {}; end;
gotChanges = 0;
if length(ud.celldrawinfo.changes)<i, ud.celldrawinfo.changes{i} = []; end;
changes = ud.celldrawinfo.changes{i};
currChanges = {};
for j=1:length(changes),   % if there are already changes, we have to overwrite them
    if strcmp(changes(j).dirname,newchanges.dirname),
        gotChanges = j; break;
    else, currChanges{end+1} = changes(j).dirname;
    end;
end;
currChanges,
if gotChanges == 0,
    if length(changes)==0,
        ud.celldrawinfo.changes{i} = newchanges;
    else,
        ud.celldrawinfo.changes{i}(end+1) = newchanges;
        currChanges{end+1} = newchanges.dirname;
        [dummy,inds]=sort(currChanges);
        ud.celldrawinfo.changes{i} = ud.celldrawinfo.changes{i}(inds);
    end;
else,
    ud.celldrawinfo.changes{i}(gotChanges) = newchanges;
end;
ud.celldrawinfo.changes{i},
set(fig,'userdata',ud);

