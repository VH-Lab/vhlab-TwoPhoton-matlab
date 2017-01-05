function refdirname = analyzetpstack_getrefdirname(ud, dirname)

%dirname, getpathname(ud.ds),

namerefs = getnamerefs(ud.ds,dirname);
match = 0;
for i=1:length(ud.slicelist),
    nr = getnamerefs(ud.ds,ud.slicelist(i).dirname);
    mtch = 1;
    for j=1:length(nr),
        for k=1:length(namerefs),
            mtch=mtch*double((strcmp(nr(j).name,namerefs(k).name)&(nr(j).ref==namerefs(k).ref)));
        end;
    end;
    if mtch==1, match = i; break; end;
end;
if match~=0, refdirname = ud.slicelist(match).dirname;
else, refdirname ='';
end;

