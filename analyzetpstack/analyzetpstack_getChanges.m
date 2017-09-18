function [changes,gotChanges] = analyzetpstack_getChanges(ud,i,newdir,ancestors)
% analyzetpstack_getChanges - get any changes to a cell in analyzetpstack (such as moved, not present, etc)
gotChanges = 0;
if isfield(ud.celldrawinfo,'changes'),
    if length(ud.celldrawinfo.changes)>=i,
        changes = ud.celldrawinfo.changes{i};
        if ~isempty(changes),
            changedirs = {changes.dirname};
            [ch,ia,ib]=intersect(ancestors,changedirs);
            if ~isempty(ch),
                changes = changes(ib(end)); gotChanges = 1;
            end;
        end;
    end;
end;
% if no changes have been specified, return the default
if ~gotChanges,
    if ~isempty(i)&~isempty(ud.celllist),
        changes = struct('present',1,'dirname',newdir,'xi',ud.celllist(i).xi,'yi',ud.celllist(i).yi,...
            'pixelinds',ud.celllist(i).pixelinds);
    else,
        changes = struct('present',1,'dirname',newdir,'xi',[],'yi',[],'pixelinds',[]);
    end;
end;

