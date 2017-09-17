function [listofcells,listofcellnames,cellstructs,thechanges] = analyzetpstack_getcurrentcellschanges(ud,refdirname,currdirname,ancestors)
listofcells = {}; listofcellnames = {}; thechanges = {};
cellstructs = analyzetpstack_emptycellrec; cellstructs = cellstructs([]);
for i=1:length(ud.celllist),
    if ~isempty(intersect(ud.celllist(i).dirname,ancestors)),
        changes = analyzetpstack_getChanges(ud,i,currdirname,ancestors);
        if changes.present,  % if the cell exists in this recording, go ahead and add it to the list
            listofcells{end+1} = changes.pixelinds;
            listofcellnames{end+1}=['cell ' int2str(ud.celllist(i).index) ' ref ' ud.celllist(i).dirname];
            cellstructs = [cellstructs ud.celllist(i)];
            thechanges{end+1} = changes;
        end;
    end;
end;

