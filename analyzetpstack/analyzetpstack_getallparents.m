function ancestors = analyzetpstack_getallparents(ud,dirname)
% ANALYZETPSTACK_GETALLPARENTS - return all directories that are at the same place and that come before a specified directory
namerefs = getnamerefs(ud.ds,dirname);
ancestors = {};
for i=1:length(ud.slicelist),
    if ~strcmp(ud.slicelist(i).dirname,dirname),
        nr = getnamerefs(ud.ds,ud.slicelist(i).dirname);
        mtch = 1;
        for j=1:length(nr),
            for k=1:length(namerefs),
                mtch=mtch*double((strcmp(nr(j).name,namerefs(k).name)&(nr(j).ref==namerefs(k).ref)));
            end;
        end;
        if mtch==1, ancestors{end+1} = ud.slicelist(i).dirname; end;
    else, break;
    end;
end;
ancestors{end+1} = dirname;
% parent should be first, followed by other ancestors, then self

