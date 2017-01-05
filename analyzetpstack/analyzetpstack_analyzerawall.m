function analyzetpstack_analyzerawall(fig, channel, dsarg, stacknamearg)
% ANALYZETPSTACK_ANALYZERAWALL - Analyze raw F from an analyzetpstack stack
%
%   ANALYZETPSTACK_ANALYZERAWALL(FIG, CHANNEL)
%     or
%   ANALYZETPSTACK_ANALYZERAWALL([], CHANNEL, DS, STACKNAME)
%
%  Inputs:  FIG - the figure number of the analyzetpstack record
%           CHANNEL - The channel number to analyze
%           DS - a DIRSTRUCT of the experiment record
%           STACKNAME - the stackname to open
%
%  Analyzes the raw fluorescence signal F from a stack.
%
%  See also:  ANALYZETPSTACK

if nargin>2,
	ud.ds = dsarg;
	stackname = stacknamearg;
	stack = load([getpathname(ud.ds) filesep 'analysis' filesep 'scratch' filesep stackname],'-mat');
	
	ud.slicelist = stack.slicelist;
	ud.celllist = stack.celllist;
	ud.celldrawinfo.changes = stack.changes;
else,
	ud = get(fig,'userdata');
	stackname = get(findobj(fig,'Tag','stacknameEdit'),'string');
	ud.ds = dirstruct(getpathname(ud.ds));
end;

T = {ud.slicelist(:).dirname};
for i=1:length(T), T{i} = trimws(T{i}); end;
%T,

for i=1:length(T),
	dirname = T{i};
	disp(['Now analyzing directory ' dirname '.']);
	refdirname = analyzetpstack_getrefdirname(ud,dirname);
	fulldirname = [fixpath(getpathname(ud.ds)) dirname];

	ancestors = getallparents(ud,dirname);  % need this

	clear listofcells listofcellnames data t
	[listofcells,listofcellnames,cellstructs]=getcurrentcellschanges(ud,refdirname,dirname,ancestors); % need this

	fname = stackname;
	scratchname = fixpath(getscratchdirectory(ud.ds,1));
	[data,t,dummy,roidata] = tpreaddata(fulldirname,[-Inf Inf],listofcells,1,channel);
	save(analyzetpstack_getrawfilename(ud.ds,stackname,dirname),'data','t','listofcells','listofcellnames','cellstructs','roidata','-mat');
end;

 % this should be pulled out some day

function ancestors = getallparents(ud,dirname)
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


function [listofcells,listofcellnames,cellstructs,thechanges] = getcurrentcellschanges(ud,refdirname,currdirname,ancestors)
listofcells = {}; listofcellnames = {}; thechanges = {};
cellstructs = analyzetpstack_emptycellrec; cellstructs = cellstructs([]);
for i=1:length(ud.celllist),
    if ~isempty(intersect(ud.celllist(i).dirname,ancestors)),
        changes = getChanges(ud,i,currdirname,ancestors);
        if changes.present,  % if the cell exists in this recording, go ahead and add it to the list
            listofcells{end+1} = changes.pixelinds;
            listofcellnames{end+1}=['cell ' int2str(ud.celllist(i).index) ' ref ' ud.celllist(i).dirname];
            cellstructs = [cellstructs ud.celllist(i)];
            thechanges{end+1} = changes;
        end;
    end;
end;


% these functions deal with setting the 'changes' field in the celllist
function [changes,gotChanges] = getChanges(ud,i,newdir,ancestors)  % cell id is i
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

