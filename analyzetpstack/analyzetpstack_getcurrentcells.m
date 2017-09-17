function [listofcells,listofcellnames,cellstructs] = analyzetpstack_getcurrentcells(ud,refdirname)
% ANALYZETPSTACK_GETCURRENTCELLS - get all cells that are 'current' in a particular directory
listofcells = {}; listofcellnames = {};
cellstructs = analyzetpstack_emptycellrec; cellstructs = cellstructs([]);
for i=1:length(ud.celllist),
    if strcmp(ud.celllist(i).dirname,refdirname),
        listofcells{end+1} = ud.celllist(i).pixelinds;
        listofcellnames{end+1}=['cell ' int2str(ud.celllist(i).index) ' ref ' ud.celllist(i).dirname];
        cellstructs = [cellstructs ud.celllist(i)];
    end;
end;
