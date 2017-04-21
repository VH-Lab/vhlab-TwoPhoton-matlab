function analyzetpstack(command, thestackname, thefig)

% ANALYZETPSTACK - Analyze two-photon stack
%
%  ANALYZETPSTACK(EXPDIRNAME, STACKNAME)
%
%   Opens a window for analyzing a stack of two-photon
%   time series.
%
%   EXPDIRNAME is the name of the day's directory.
%
%   STACKNAME is a string containing the name of
%   the stack.  It can be anything that can be
%   part of a valid filename.  If the stackname
%   already exists then it is opened for viewing.
%

% Change log:
% GS 8_1_10
%   a. zoom and pan toggles (are toggled off if another button in UI is clicked). Note these functions are 
%         called through their own callbacks, not using the analyzetpstack('comand',...) structure. 
%   b. hotkeys (only work sometimes - correct objects within UI must be selected...). Also added button to turn hotkeys off.
%       HOTKEYS:
%         space-toggle DrawCells; m-move cell; delete-delete cell;'
%         'd-draw circ until; p-toggle present'
%   c. rearranged window - large imaging area. Window still not resizable.

NUMPREVIEWFRAMES = 1;  % this no longer has meaning for the number of preview frames, which are all handled by external functions now; it needs to be set to 1 so drift is drawn correctly
TwoPhotonGlobals;

if nargin==2, % command is actually experiment directoryar name
    dirname = command;
    command = 'NewWindow';
    ud.ds = dirstruct(dirname);
    fig = figure;
    % 	set(fig,'Tag','analyzetpstack','position',[381 217 630 650]); % old pos
    set(fig,'Tag','analyzetpstack','position',[47 50 1284 778]); % new pos
    set(fig,'KeyPressFcn',{@hotkeyreader fig})
    stackname = thestackname;
end;

if nargin==3,  % then is command w/ fig as 3rd arg
    fig = thefig;
    ud = get(fig,'userdata');
    stackname = get(ft(fig,'stacknameEdit'),'string');
end;

if ~isa(command,'char'),
    % if not a string, then command is a callback object
    command = get(command,'Tag');
    fig = gcbf;
    
    ud = get(fig,'userdata');
    stackname = get(ft(fig,'stacknameEdit'),'string');
end;

command,
try set(ft(fig,'lastcmd'),'string',['Last command: ' command]); 
catch
disp('caught')    
end %updates figure display to
% reflect last command run. Within try segment to prevent error on first
% window creation where this box doesn't exist yet
if ~strcmp(command,'NewWindow')
    set(ft(fig,'zoomtog'),'value',0)
    set(ft(fig,'pantog'),'value',0)
end

switch command,
    case 'NewWindow',
        
        button.Units = 'pixels';
        button.BackgroundColor = [0.8 0.8 0.8]*0.94/0.8;
        button.HorizontalAlignment = 'center';
        button.Callback = 'genercallback';
        txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8]*0.94/0.8;
        txt.fontsize = 12; txt.fontweight = 'normal';
        txt.HorizontalAlignment = 'center';txt.Style='text';
        edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';
        popup = txt; popup.style = 'popupmenu';
        cb = txt; cb.Style = 'Checkbox'; cb.Callback = 'genercallback';
        cb.fontsize = 12;
        
        sh=50+10;
	% this is now handled in analyzetpstack_previewimage
        %h=axes('units','pixels','position',[5 5 770 770],'Tag','tpaxes','box','off','YTick',[],'XTick',[]);
        sh=sh+40;
        
        sh=sh-30;
        
        sh=sh+10;
        xsh=120;
               
        % move these guys up (lazy code by GS - reassign sh, put back when done -
        shold=sh;
        sh=sh+370;
        myu=uicontrol(popup,'position',[225 162+sh 110 20],'String',{'Auto draw cells'},...
            'Tag','autoDrawCellsPopup','Enable','on','Callback','genercallback');
	analyzetpstack_draw_devs_menu('init', myu, '');
        uicontrol(button,'position',[225 142+sh 110 20],'String','Draw new cell',...
            'Tag','drawnewBt');
        uicontrol(button,'position',[225 120+sh 110 20],'String','Draw circles until <return>',...
            'Tag','drawnewballBt','fontsize',9);
        uicontrol(txt,'position',[225 100-2+sh 50 20],'String','Dia.:');
        uicontrol(edit,'position',[225+50 100+sh 40 20],'String','12','Tag','newballdiameterEdit');
        uicontrol(button,'position',[225 80+sh 110 20],'String','Redraw cell','Tag','redrawCellBt');
        uicontrol(cb, 'position', [225 40+sh 110 20],'String','Present','value',1,...
            'Tag','presentCB','callback','genercallback');

        uicontrol(popup,'position',[225 20+sh 110 20],'String',tpstacktypes,'Tag','cellTypePopup','callback','genercallback');
        sh=shold;
        
        uicontrol(txt,'position',[10+xsh -5+sh 200 20],'String','Cell labels:','value',1);
        uicontrol('Units','pixels','position',[10+xsh -70+sh 200 70],...
            'Style','list','BackgroundColor',[1 1 1],'Tag','labelList',...
            'Callback','genercallback','string',tpstacklabels,'Max',2);
        sh=sh-30;
        
        sh = sh+50-10;
	sssssh = sh;
        uicontrol(txt,'position',[338 528+sh 80 20],'String','Stack',...
            'horizontalalignment','center');
        uicontrol(edit,'position',[425 530+sh 80 20],'String',stackname,'Tag','stacknameEdit');
        uicontrol(button,'position',[515 530+sh 30 20],'String','Load','Tag','loadBt');
        uicontrol(button,'position',[545 530+sh 30 20],'String','Save','Tag','saveBt');
        %uicontrol(button,'position',[500 500+sh 70 20],'String','Add new slice','Tag','addsliceBt');
        uicontrol(txt,'position',[338 500+sh 70 20],'String','Slices:');
        
        uicontrol(button,'position',[490 430+sh 120 20],'String','Add slice to DB','Tag','AddDBBt');
        uicontrol(button,'position',[490 400+sh 120 20],'String','Link to larger image','Tag','AddDBBt');
        uicontrol(button,'position',[490 370+sh 120 20],'String','Check cell alignment','Tag','checkAlignmentBt');
        
        uicontrol(button,'position',[350 350+sh 130 130],'Style','list','String','',...
            'callback','genercallback','Tag','sliceList','Backgroundcolor',[1 1 1]);
        
        sh = -150+100;
        uicontrol(txt,'position',[340 470-2+sh 50 20],'String','depth:');
        uicontrol(edit,'position',[340+50 470+sh 50 20],'String','','Tag','depthEdit',...
            'Callback','genercallback');
        uicontrol(txt,'position',[440+5 470-2+sh 75 20],'String','XY offset:','Tag','sliceOffsetText');
        uicontrol(edit,'position',[440+75+5 470-2+sh 80 20],'String','[0 0]','Tag','sliceOffsetEdit','callback','genercallback');
        uicontrol(cb,'position',[340 440+sh 100 20],'String','Draw cells','Tag','DrawCellsCB');
        uicontrol(cb,'position',[440 440+sh 130 20],'String','Draw linescans','Tag','DrawLinescansCB');
        %uicontrol(button,'position',[340 420+sh 100 20],'String','Remove slice','Tag','RemoveSliceBt');
        
        sh = 80+50+50-5;
        uicontrol(txt,'position',[340 163+sh 150 20],'String','Response analysis:','Fontsize',16);
        uicontrol(txt,'position',[340 135-2+sh 60 20],'String','Dir name:');
        uicontrol(edit,'position',[340+60 135+sh 100 20],'String','t00001','Tag','stimdirnameEdit','callback','genercallback');
        uicontrol(txt,'position',[340+60+105 135-2+sh 60 20],'String','Channel:');
        uicontrol(edit,'position',[340+60+105+65 135+sh 50 20],'String','1','Tag','stimChannelEdit');
        uicontrol(txt,'position',[340 110-2+sh 60 20],'String','Param:');
        uicontrol(edit,'position',[340+60 110+sh 100 20],'String','angle','Tag','stimparamnameEdit');
        uicontrol(txt,'position',[340 90-2+sh 60 20],'String','Trials:');
        uicontrol(edit,'position',[340+60 90+sh 100 20],'String','','Tag','trialsEdit');
        uicontrol(txt,'position',[340+160 90-4+sh 100 20],...
            'String','(blank for default)','fontsize',9,'horizontalalignment','left');
        uicontrol(txt,'position',[340 90-2+sh-20 60 20],'String','T ints:');
        uicontrol(edit,'position',[340+60 90+sh-20 60 20],'String','','Tag','timeintEdit');
        uicontrol(edit,'position',[340+120 90+sh-20 60 20],'String','','Tag','sptimeintEdit');
        uicontrol(txt,'position',[340+180 90-4+sh-20 100 20],...
            'String','([time int],[spont int])','fontsize',9,'horizontalalignment','left');
        uicontrol(txt,'position',[340 90-2+sh-40 60 20],'String','Blank:');
        uicontrol(edit,'position',[340+60 90+sh-40 60 20],'String','','Tag','BlankIDEdit');
        uicontrol(txt,'position',[340+160 90-4+sh-40 100 20],...
            'String','(empty for default)','fontsize',9,'horizontalalignment','left');
        sh=sh-25-25-10;
        uicontrol(button,'position',[340 85+sh 100 20],'String','Analyze by param',...
            'Tag','AnalyzeParamBt');
        uicontrol(button,'position',[340+105 85+sh 100 20],'String','Analyze by stim #',...
            'Tag','AnalyzeStimBt');
        uicontrol(button,'position',[340+105+105 85+sh 70 20],'String','Raw',...
            'Tag','AnalyzeRawBt');
        uicontrol(button,'position',[340 60+sh 100 20],'String','Quick PSTH',...
            'Tag','QuickPSTHBt');
        uicontrol(edit,'position',[445 60+sh 50 20],'String','0.25',...
            'Tag','QuickPSTHEdit');
        uicontrol(cb,'position',[445+50 60+sh 80 20],'String','Smooth','value',0,'Tag','QuickPSTHCB');
        uicontrol(button,'position',[340 35+sh 100 20],'String','ImageMath',...
            'Tag','ImageMathBt');
        uicontrol(edit,'position',[445 35-2+sh 100 20],'String','1 - 5',...
            'Tag','ImageMathEdit');
        uicontrol(button,'position',[340 35+sh 100 20],'String','ImageMath',...
            'Tag','ImageMathBt');
        uicontrol(button,'position',[340 35-25+sh 120 20],'string','Single conditions','Tag','singleCondBt');
        %uicontrol(edit,'position',[340+120+5 35-25+sh 100 20],'string','','Tag','singleCondEdit');
        sh = sh-25;
	uicontrol(button,'position',[340 10+sh 100 20],'String','Quick Map','Tag','QuickMapBt');
	uicontrol(edit,'position',[445 10+sh 100 20],'String','0.05','Tag','mapthreshEdit');
	uicontrol(button,'position',[340 -15+sh 60 20],'String','Movie','Tag','movieBt');
	uicontrol(edit,'position',[345+60 -15+sh 40 20],'String','','Tag','movieStimsEdit');
	uicontrol(edit,'position',[345+60+45 -15+sh 80 20],'String','movie.avi','Tag','movieFileEdit');
	uicontrol(cb,'position',[345+60+45+85 -15+sh 40 20],'String','dF','Tag','moviedFCB','value',0);
	uicontrol(cb,'position',[345+60+45+85+40 -15+sh 50 20],'String','sort','Tag','movieSortCB','value',0);
	myudrift=uicontrol(popup,'position',[340 -25-15+sh 150 20],'String',{'Drift correction'},...
		'Tag','DriftMenuPopup','Enable','on','Callback','genercallback');
	analyzetpstack_drift_devs_menu('init', myudrift, '');
	%uicontrol(button,'position',[340 -25-15+sh 100 20],'String','Correct drift','Tag','correctDriftBt');
	%uicontrol(button,'position',[445 -25-15+sh 60 20],'String','Man.shift','tag','shiftDriftBt');
        uicontrol(button,'position',[550 -25-15+sh 60 20],'String','Check drift','Tag','checkDriftBt');
        
        h=findobj(gcf);
        xshift=660;
        for i=1:length(h)
            if h(i)~=findobj(gcf,'type','figure') & ~strcmp(get(h(i),'type'),'axes') 
                try,
                    set(h(i),'position',get(h(i),'position')+[xshift 0 0 0]);
                catch,
                end;
            end
        end
        uicontrol(button,'position',[883 436 110 20],'String','Delete cell','Tag','deletecellBt');
        
        uicontrol(button,'position',[883 510 110 20],'String','Move cell','Tag','moveCellBt');
        uicontrol('Units','pixels','position',[790 90 200 310],...
            'Style','list','BackgroundColor',[1 1 1],'Tag','celllist',...
            'Callback','genercallback','keypressfcn',{@hotkeyreader fig});
        uicontrol(txt,'position',[790 405 200 20],'String','Cells: id#|slice#');
        uicontrol(cb, 'position', [1008 12 140 20],'String','Enable Hotkeys','value',1,...
            'Tag','hotkey','callback','genercallback','tooltip',...
            ['HotKeys: space-toggle DrawCells; m-move cell; delete-delete cell;'...
            'd-draw circ until; p-toggle present']);

	uicontrol('style','togglebutton','string','Zoom','callback',@zoomtogcb,'tag','zoomtog','position',[780 460 50 20])
        uicontrol('style','togglebutton','string','Pan','callback',@pantogcb,'tag','pantog','position',[780 435 50 20])

	set(fig,'userdata',ud); % the following command operates on userdata
	analyzetpstack_previewimage('previewWindowInit',stackname,fig);
	ud = get(fig,'userdata');  % get the new userdata back

        uicontrol(txt,'position',[1000 704 280 20],'String',['Last command: ' command],'tag','lastcmd');
        
        % now make data structures
        slicelist = analyzetpstack_emptyslicerec; slicelist = slicelist([]);
        celllist = analyzetpstack_emptycellrec; celllist = celllist([]);
        ud.slicelist = slicelist;
	ud.celllist = celllist;
        ud.celldrawinfo.dirname = [];
        ud.celldrawinfo.h = [];
        ud.celldrawinfo.t = [];
        
	analyzetpstack_slicelist('sliceListInit',[],fig,[400+660 500+sssssh 200 20]);
        
        set(fig,'userdata',ud);
        
    case 'UpdateCellList',
        v_ = get(ft(fig,'celllist'),'value');
        strlist = {};
        for i=1:length(ud.celllist),
            strlist{i} = [num2str(ud.celllist(i).index) ' | ' ud.celllist(i).dirname];
        end;
        set(ft(fig,'celllist'),'string',strlist);
        if v_>length(strlist),
            if length(strlist)>=1, v=1;
            else, v=[];
            end;
        elseif isempty(v_), v=1;
        else, v=v_;
        end;
        set(ft(fig,'celllist'),'value',v);
        analyzetpstack('UpdateCellLabels',[],fig);
        analyzetpstack('UpdateCellImage',[],fig);
    case 'channelPopup',
	error(['Should not happen anymore; should be handled by analyzetpstack_previewimage.m']);
        analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
    case 'ColorMaxEdit',
	error(['Should not happen anymore; should be handled by analyzetpstack_previewimage.m']);
        ud.previewdir = '';
        set(fig,'userdata',ud);
        analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
    case 'ColorMinEdit',
	error(['Should not happen anymore; should be handled by analyzetpstack_previewimage.m']);
        analyzetpstack('ColorMaxEdit',[],fig);
    case 'UpdateCellImage',
        cv = get(ft(fig,'celllist'),'value');
        sv = get(ft(fig,'sliceList'),'value');
        newdir = get(ft(fig,'sliceList'),'string');
        newdir = trimws(newdir{sv});
        parentdir=analyzetpstack_getrefdirname(ud,newdir);  % is there a parent directory?
        ancestors=getallparents(ud,newdir);  % is there a parent directory?
        %bg color is red, fg is blue, highlighted is yellow
        if length(ud.celldrawinfo.h)~=length(ud.celllist),
            % might need to draw cells
            % we do when we are drawing for first time
            % or if we are adding a cell
            drift = analyzetpstack_getdirdrift(ud,newdir);
            xyoffset = analyzetpstack_getxyoffset(ud,newdir);
            total_drift = drift + xyoffset;
            if 1+length(ud.celldrawinfo.h)<=length(ud.celllist),
                start = 1+length(ud.celllist)-(-length(ud.celldrawinfo.h)+length(ud.celllist));
            elseif length(ud.celldrawinfo.h)==0,
                start = 1;
            else,  % maybe we removed some cells, start over
                try, delete(ud.celldrawinfo.h); end;
                try, delete(ud.celldrawinfo.t); end;
                ud.celldrawinfo.h = []; ud.celldrawinfo.t = [];
                start = 1;
            end;
            slicelistlookup.test = [];
            for j=1:length(ud.slicelist),
                slicelistlookup=setfield(slicelistlookup,trimws(ud.slicelist(j).dirname),j);
            end;
            for i=start:length(ud.celllist),
                axes(ft(fig,'tpaxes'));
                hold on;
                xi = ud.celllist(i).xi;
		xi(end+1) = xi(1);
                yi = ud.celllist(i).yi;
		yi(end+1) = yi(1);
                ud.celldrawinfo.h(end+1) = plot(xi-total_drift(1),yi-total_drift(2),'linewidth',2);
                ud.celldrawinfo.t(end+1) = text(mean(xi)-total_drift(1),mean(yi)-total_drift(2),...
                    int2str(ud.celllist(i).index),...
                    'fontsize',12,'fontweight','bold','horizontalalignment','center');
                set(gca,'tag','tpaxes');
                if getfield(ud.slicelist(getfield(slicelistlookup,ud.celllist(i).dirname)),'drawcells'),
                    visstr = 'on';
                else, visstr = 'off';
                end;
                if strcmp(newdir,ud.celllist(i).dirname),
                    set(ud.celldrawinfo.h(end),'color',[0 0 1],'visible',visstr);
                    set(ud.celldrawinfo.t(end),'color',[0 0 1],'visible',visstr);
                else,
                    set(ud.celldrawinfo.h(end),'color',[1 0 0],'visible',visstr);
                    set(ud.celldrawinfo.t(end),'color',[1 0 0],'visible',visstr);
                end;
            end;
        end;
        slicestruct = [];
        if ~strcmp(ud.celldrawinfo.dirname,newdir),
            disp(['Redrawing for new directory.']);
            % user selected a new directory and we have to recolor
            for i=1:length(ud.celllist),
                slicestruct = updatecelldraw(ud,i,slicestruct,newdir,NUMPREVIEWFRAMES);
            end;
            ud.celldrawinfo.dirname = newdir;
        end; % redrawing for new directory
        highlighted = findobj(ft(fig,'tpaxes'),'color',[1 1 0]);
        [handles,hinds] = intersect(ud.celldrawinfo.h,highlighted);
        for i=1:length(hinds),
            if hinds(i) ~= cv, % if it shouldn't be highlighted
                slicestruct = updatecelldraw(ud,hinds(i),slicestruct,newdir,NUMPREVIEWFRAMES);
            end;
        end;
        % now highlight appropriate cell
        if ~isempty(ud.celldrawinfo.h),
            slicestruct = updatecelldraw(ud,cv,slicestruct,newdir,NUMPREVIEWFRAMES);
            set(ud.celldrawinfo.h(cv),'color',[1 1 0],'visible','on');
            set(ud.celldrawinfo.t(cv),'color',[1 1 0],'visible','on');
        end;
        set(fig,'userdata',ud);
    case 'UpdateCellLabels',
        v = get(ft(fig,'celllist'),'value');
        if ~isempty(ud.celllist),
            [dummy,newvals]=intersect(get(ft(fig,'labelList'),'string'),ud.celllist(v).labels);
            [dummy,newtypev]=intersect(get(ft(fig,'cellTypePopup'),'string'),ud.celllist(v).type);
        else, newvals = 1; newtypev = 1;
        end;
        set(ft(fig,'labelList'),'value',newvals);
        set(ft(fig,'cellTypePopup'),'value',newtypev);
        sv = get(ft(fig,'sliceList'),'value');
        newdir = get(ft(fig,'sliceList'),'string');
        newdir = trimws(newdir{sv});
        parentdir=analyzetpstack_getrefdirname(ud,newdir);  % is there a parent directory?
        if isempty(ud.celllist), AA = 0; else, AA = strcmp(newdir,ud.celllist(v).dirname); end;
        if isempty(parentdir)|strcmp(parentdir,newdir)|AA,
            set(ft(fig,'presentCB'),'enable','off','value',1);
        else,
            ancestors=getallparents(ud,newdir);
            changes = getChanges(ud,v,newdir,ancestors);
            value = changes.present;
            set(ft(fig,'presentCB'),'enable','on','value',value);
        end;
    case 'DrawCellsCB',
        sv = get(ft(fig,'sliceList'),'value');
        ud.slicelist(sv).drawcells = 1-ud.slicelist(sv).drawcells;
        ud.celldrawinfo.dirname = '';
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellImage',[],fig);
    case 'DrawLinescansCB',
        sv = get(ft(fig,'sliceList'),'value');
        ud.slicelist(sv).analyzecells = 1-ud.slicelist(sv).analyzecells;
        ud.celldrawinfo.dirname = '';
        set(fig,'userdata',ud);
        analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
    case 'sliceList',
        analyzetpstack_slicelist('UpdateSliceDisplay',[],fig);
    case 'celllist',
        analyzetpstack('UpdateCellLabels',[],fig);
        analyzetpstack('UpdateCellImage',[],fig);
    case 'presentCB',
        v = get(ft(fig,'celllist'),'value');
        sv = get(ft(fig,'sliceList'),'value'); currdir = get(ft(fig,'sliceList'),'string'); currdir = trimws(currdir{sv});
        parentdir=analyzetpstack_getrefdirname(ud,currdir);  % is there a parent directory?
        ancestors=getallparents(ud,currdir);  % is there a parent directory?
        if ~isempty(parentdir)&~strcmp(parentdir,currdir)&~strcmp(currdir,ud.celllist(v).dirname), % can't make changes if this is a parent directory
            changes = getChanges(ud,v,currdir,ancestors);
            changes.present = get(ft(fig,'presentCB'),'value');
            changes.dirname = currdir;
            setChanges(ud,fig,v,changes);
            ud=get(fig,'userdata');
        end;
        ud.celldrawinfo.dirname = '';
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellImage',[],fig);
    case 'hotkey'
        if get(ft(fig,'hotkey'),'value')==0
            set(fig,'KeyPressFcn',[])
            set(ft(fig,'celllist'),'KeyPressFcn',[]);
        else if get(ft(fig,'hotkey'),'value')==1
                set(fig,'KeyPressFcn',{@hotkeyreader fig})
                set(ft(fig,'celllist'),'KeyPressFcn',{@hotkeyreader fig});
            end
        end
    case 'moveCellBt',
        v = get(ft(fig,'celllist'),'value');
        sv = get(ft(fig,'sliceList'),'value'); currdir = get(ft(fig,'sliceList'),'string'); currdir = trimws(currdir{sv});
        ancestors=getallparents(ud,currdir);
        cellisinthisimage = ~isempty(intersect(ud.celllist(v).dirname,ancestors));
        cellisactualcell = strcmp(ud.celllist(v).dirname,currdir);
        if ~cellisinthisimage,
            disp(['Cannot move cell whose preview image is not being viewed.']); return;
        end;
        % at this point, we are going to make a move so let's get the coordinate
        disp(['Click new center location.']);
        [x,y] = ginput(1);
        previewimhandle = analyzetpstack_previewimage('GetPreviewImageHandle',[],fig);
        sz = size(get(previewimhandle,'CData'));
        [blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));
        drift = analyzetpstack_getdirdrift(ud, currdir);
	xyoffset = analyzetpstack_getxyoffset(ud, currdir);
	totaldrift = drift + xyoffset;
        if cellisactualcell,
            cr = ud.celllist(v);
            cr.xi = ud.celllist(v).xi - mean(ud.celllist(v).xi) + x + totaldrift(1) ;
            cr.yi = ud.celllist(v).yi - mean(ud.celllist(v).yi) + y + totaldrift(2);
            bw = inpolygon(blankprev_x,blankprev_y,cr.xi,cr.yi);
            cr.pixelinds = find(bw);
            ud.celllist(v) = cr;
            if 0,
                im0 = zeros(size(get(previewimhandle,'CData')));
                figure;
                im0(bw) = 255;
                image(im0);
            end;
        else, %
		changes = getChanges(ud,v,currdir,ancestors);
		changes.xi = ud.celllist(v).xi+totaldrift(1)-mean(ud.celllist(v).xi)+x;
		changes.yi = ud.celllist(v).yi+totaldrift(2)-mean(ud.celllist(v).yi)+y;
		bw = inpolygon(blankprev_x,blankprev_y,changes.xi,changes.yi);
		changes.pixelinds = find(bw);
		changes.dirname = currdir;
		if 0,
			im0 = zeros(size(get(previewimhandle,'CData')));
			figure;
			im0(bw) = 255;
			image(im0);
		end;
		setChanges(ud,fig,v,changes);
		ud = get(fig,'userdata');
        end;
        ud.celldrawinfo.dirname = '';
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellImage',[],fig);
    case 'redrawCellBt',
        v = get(ft(fig,'celllist'),'value');
        sv = get(ft(fig,'sliceList'),'value'); currdir = get(ft(fig,'sliceList'),'string'); currdir = trimws(currdir{sv});
        ancestors=getallparents(ud,currdir);
        cellisinthisimage = ~isempty(intersect(ud.celllist(v).dirname,ancestors));
        cellisactualcell = strcmp(ud.celllist(v).dirname,currdir);
        if ~cellisinthisimage,
            disp(['Cannot redraw cell whose preview image is not being viewed.']); return;
        end;
        % at this point, we are going to redraw so let's have the user redraw
        disp(['Draw new ROI for cell.']);
        axes(ft(fig,'tpaxes'));
        zoom off;
        [bw,xi,yi]=roipoly();
        % now what happens is different
        drift = analyzetpstack_getdirdrift(ud, currdir);
	xyoffset = analyzetpstack_getxyoffset(ud, currdir);
	total_drift = drift + xyoffset;
        previewimhandle = analyzetpstack_preview('GetCurrentPreviewImageHandle',[],fig);
        if cellisactualcell,
		cr = ud.celllist(v);
		cr.xi = xi+total_drift(1);
		cr.yi = yi+total_drift(2);
		cr.pixelinds = find(bw);
		ud.celllist(v) = cr;
		if 0,
			im0 = zeros(size(get(previewimhandle,'CData')));
			figure;
			im0(bw) = 255;
			image(im0);
		end;
        else, %
		sz = size(get(previewimhandle,'CData'));
		[blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));
		changes = getChanges(ud,v,currdir,ancestors);
		changes.xi = xi+total_drift(1);
		changes.yi = yi+total_drift(2);
		bw = inpolygon(blankprev_x,blankprev_y,changes.xi,changes.yi);
		changes.pixelinds = find(bw);
		changes.dirname = currdir;
		if 0,
			im0 = zeros(size(get(previewimhandle,'CData')));
			figure;
			im0(bw) = 255;
			image(im0);
		end;
		setChanges(ud,fig,v,changes);
		ud = get(fig,'userdata');
        end;
        ud.celldrawinfo.dirname = '';
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellImage',[],fig);
    case 'labelList',
        strs = get(ft(fig,'labelList'),'string');
        vals = get(ft(fig,'labelList'),'value');
        v = get(ft(fig,'celllist'),'value');
        for i=1:length(v), ud.celllist(v(i)).labels = strs(vals); end;
        set(fig,'userdata',ud);
    case 'cellTypePopup',
        strs = get(ft(fig,'cellTypePopup'),'string');
        val = get(ft(fig,'cellTypePopup'),'value');
        v = get(ft(fig,'celllist'),'value');
        for i=1:length(v), ud.celllist(v(i)).type= strs{val}; end;
        set(fig,'userdata',ud);
    case 'autoDrawCellsPopup',
        v = get(ft(fig,'sliceList'),'value');
        dirname = trimws(ud.slicelist(v).dirname);
	inputs.dirname = dirname;
	inputs.ds = ud.ds;
	inputs.fullpathdirname = [getpathname(ud.ds) filesep inputs.dirname];
        typestr = get(ft(fig,'cellTypePopup'),'string');
        labelstr = get(ft(fig,'labelList'),'string');
	inputs.default_type_string= typestr{get(ft(fig,'cellTypePopup'),'value')};
	inputs.default_label_strings= labelstr(get(ft(fig,'labelList'),'value'));
	if isempty(ud.celllist),
		inputs.cell_index_counter = 0;
	else,
		inputs.cell_index_counter = max([ud.celllist.index]);
	end;
        drift = analyzetpstack_getdirdrift(ud,dirname);
	xyoffset = analyzetpstack_getxyoffset(ud,dirname);
	total_drift = drift + xyoffset;
	inputs.drift = total_drift;
	inputs.previewim= analyzetpstack_previewimage('GetPreviewImage',[],fig);
	celllist = analyzetpstack_draw_devs_menu('handleclick',ft(fig,'autoDrawCellsPopup'),inputs);
	if ~isempty(celllist),
		ud.celllist = [ud.celllist celllist];
		set(fig,'userdata',ud);
		analyzetpstack('UpdateCellList',[],fig);
	end;
    case 'autoDrawCellsBt',
        v = get(ft(fig,'sliceList'),'value');
        dirname = trimws(ud.slicelist(v).dirname);
        [dummy,params] = find_cellsMM;
        % now autofind the cells
	mypreviewim= analyzetpstack_previewimage('GetPreviewImage',[],fig);
        cell_list=find_cellsMM(mypreviewimage,params);
        typestr = get(ft(fig,'cellTypePopup'),'string');
        labelstr = get(ft(fig,'labelList'),'string');
        for i=1:length(cell_list),
            newcell = analyzetpstack_emptycellrec;
            newcell.dirname = dirname;
            newcell.pixelinds = cell_list(i).pixelinds;
            newcell.xi = cell_list(i).xi;
            newcell.yi = cell_list(i).yi;
            newcell.type = typestr{get(ft(fig,'cellTypePopup'),'value')};
            newcell.labels= labelstr(get(ft(fig,'labelList'),'value'));
            if ~isempty(ud.celllist),
                newcell.index = max([ud.celllist.index])+1;
            else, newcell.index = 1;
            end;
            ud.celllist = [ud.celllist newcell];
        end;
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellList',[],fig);
    case 'drawnewBt',
        v = get(ft(fig,'sliceList'),'value');
        dirname = trimws(ud.slicelist(v).dirname);
        dr = analyzetpstack_getdirdrift(ud,dirname);
	xyoffset = analyzetpstack_getxyoffset(ud,dirname);
	total_drift = dr + xyoffset;
        figure(fig);
        axes(ft(fig,'tpaxes'));
        zoom off;
        [bw,xi,yi]=roipoly();
        newcell=analyzetpstack_emptycellrec;
        newcell.dirname = dirname;
        newcell.pixelinds = find(bw);
        newcell.xi = xi+total_drift(1);
	newcell.yi = yi+total_drift(2);
        typestr = get(ft(fig,'cellTypePopup'),'string');
        newcell.type = typestr{get(ft(fig,'cellTypePopup'),'value')};
        labelstr = get(ft(fig,'labelList'),'string');
        newcell.labels= labelstr(get(ft(fig,'labelList'),'value'));
        if ~isempty(ud.celllist),
		newcell.index = max([ud.celllist.index])+1;
        else,
		newcell.index = 1;
        end;
        ud.celllist = [ud.celllist newcell];
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellList',[],fig);
    case 'drawnewballBt',
        v = get(ft(fig,'sliceList'),'value');
        dirname = trimws(ud.slicelist(v).dirname);
        dr = analyzetpstack_getdirdrift(ud,dirname);
	xyoffset = analyzetpstack_getxyoffset(ud,dirname);
	total_drift = dr + xyoffset;
        figure(fig);
        axes(ft(fig,'tpaxes'));
        zoom off;
        sz = size(get(ud.previewim,'CData'));
        [blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));
        newballdiastr = get(ft(fig,'newballdiameterEdit'),'string');
        if ~isempty(newballdiastr),
            try, newballdia = eval(newballdiastr);
            catch, newballdia = 12;
            end;
        else, newballdia = 12;
        end;
        rad = round(newballdia/2);
        xi_ = ((-rad):1:(rad));
        yi_p = sqrt(rad^2-xi_.^2);
        yi_m = - sqrt(rad^2-xi_.^2);
        [x,y] = ginput(1);
        while ~isempty(x),
            xi = [xi_ xi_(end:-1:1)]+x+total_drift(1);
            yi = [yi_p yi_m(end:-1:1)]+y+total_drift(2);
		%[x y]
		%[x+total_drift(1) y+total_drift(2)]
            bw = inpolygon(blankprev_x,blankprev_y,xi,yi);
            %figure; image(bw*255); colormap(gray(256)); figure(fig);
            %hold on; plot(xi,yi,'r','linewidth',2);
            
            newcell=analyzetpstack_emptycellrec;
            newcell.dirname = dirname;
            newcell.pixelinds = find(bw);
            newcell.xi = xi; newcell.yi = yi;
            typestr = get(ft(fig,'cellTypePopup'),'string');
            newcell.type = typestr{get(ft(fig,'cellTypePopup'),'value')};
            labelstr = get(ft(fig,'labelList'),'string');
            newcell.labels= labelstr(get(ft(fig,'labelList'),'value'));
            if ~isempty(ud.celllist),
                newcell.index = max([ud.celllist.index])+1;
            else, newcell.index = 1;
            end;
            ud.celllist = [ud.celllist newcell];
            set(fig,'userdata',ud);
            analyzetpstack('UpdateCellList',[],fig);
            ud=get(fig,'userdata');
            figure(fig);
            [x,y]=ginput(1);
        end;
    case 'deletecellBt',
        v = get(ft(fig,'celllist'),'value');
        ud.celllist = [ud.celllist(1:(v-1)) ud.celllist((v+1):end)];
        delete(ud.celldrawinfo.h(v)); delete(ud.celldrawinfo.t(v));
        if isfield(ud.celldrawinfo,'changes'),
            if length(ud.celldrawinfo.changes)>=v,
                ud.celldrawinfo.changes = ud.celldrawinfo.changes([1:(v-1) (v+1):length(ud.celldrawinfo.changes)]);
            end;
        end;
        ud.celldrawinfo.h= [ud.celldrawinfo.h(1:(v-1)) ud.celldrawinfo.h((v+1):end)];
        ud.celldrawinfo.t= [ud.celldrawinfo.t(1:(v-1)) ud.celldrawinfo.t((v+1):end)];
        set(fig,'userdata',ud);
        analyzetpstack('UpdateCellList',[],fig);
    case 'depthEdit',
        v = get(ft(fig,'sliceList'),'value');
        try,
            ud.slicelist(v).depth = str2num(get(ft(fig,'depthEdit'),'string'));
        catch, errordlg(['Syntax error in depth. Value not changed.']);
        end;
        set(fig,'userdata',ud);
    case 'sliceOffsetEdit',
        v = get(ft(fig,'sliceList'),'value');
        try,
            xyoffset = str2num(get(ft(fig,'sliceOffsetEdit'),'string'));
            if ~eqlen(size(xyoffset),[1 2]), error('xyoffset wrong size.'); end;
            ud.slicelist(v).xyoffset = xyoffset;
        catch, errordlg(['Error in XY Offset. Value not changed.']);
        end;
        ud.previewdir = '';
        ud.celldrawinfo.dirname = '';
        set(fig,'userdata',ud);
        analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
        analyzetpstack('UpdateCellImage',[],fig);
    case {'AnalyzeParamBt','AnalyzeStimBt','AnalyzeDragoiStimBt','AnalyzeRawBt'},
        ud.ds = dirstruct(getpathname(ud.ds));
        dirname = get(ft(fig,'stimdirnameEdit'),'string');
        refdirname = analyzetpstack_getrefdirname(ud,dirname);
        fulldirname = [fixpath(getpathname(ud.ds)) dirname];
        if strcmp(command,'AnalyzeParamBt'), paramname = get(ft(fig,'stimparamnameEdit'),'string');
        else, paramname = []; end;
        trialsstr = get(ft(fig,'trialsEdit'),'string');
        if ~isempty(trialsstr), trialslist = eval(trialsstr); else, trialslist = []; end;
        timeintstr = get(ft(fig,'timeintEdit'),'string');
        if ~isempty(timeintstr), timeint= eval(timeintstr); else, timeint= []; end;
        sptimeintstr = get(ft(fig,'sptimeintEdit'),'string');
        if ~isempty(sptimeintstr), sptimeint= eval(sptimeintstr); else, sptimeint= []; end;
        blankIDstr = get(ft(fig,'BlankIDEdit'),'string');
        if ~isempty(blankIDstr), blankID = eval(blankIDstr); else, blankID = []; end;
        ancestors = getallparents(ud,dirname);
        [listofcells,listofcellnames,cellstructs]=getcurrentcellschanges(ud,refdirname,dirname,ancestors);
        fname = stackname; scratchname = fixpath(getscratchdirectory(ud.ds,1));
        needtorun = 1;
        channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
	try,
		g = analyzetpstack_loadrawfile(ud.ds,stackname,dirname);
            	needtorun = ~(g.listofcellnames==listofcellnames);
		if ~needtorun, needtorun = ~eqlen(g.listofcells,listofcells); end;
		if ~needtorun, needtorun = isfield(g,'cellstructs'); end;
	end;
        if needtorun,
            [data,t] = tpreaddata(fulldirname,[-Inf Inf],listofcells,1,channel);
            save(analyzetpstack_getrawfilename(ud.ds,stackname,dirname),'data','t','listofcells','listofcellnames','cellstructs','-mat');
        end;
        pixelarg = analyzetpstack_loadrawfile(ud.ds,stackname,dirname);
        fprintf('Analyzing...will take several seconds...\n');
        paramname,
        if strcmp(command,'AnalyzeRawBt'),
            resps=pixelarg;
            figure;
            colors=[ 1 0 0;0 1 0;0 0 1;1 1 0;0 1 1;1 1 1;0.5 0 0;0 0.5 0;0 0 0.5;0.5 0.5 0;0.5 0.5 0.5];
            thenames = {};
            for i=1:length(pixelarg.data),
                hold on;
                ind=mod(i,length(colors)); if ind==0,ind=length(colors); end;
                if ~isempty(pixelarg.data{i})
                    plot(pixelarg.t{i},pixelarg.data{i},'color',colors(ind,:));
                    thenames = cat(1,thenames,pixelarg.listofcellnames{i});
                end;
            end;
            legend(thenames);
            ylabel('Raw signal'); xlabel('Time (s)');
        elseif ~strcmp(command,'AnalyzeDragoiStimBt'),
            % first no plot, then save, then plot
            resps=tptuningcurve(fulldirname,channel,paramname,pixelarg,0,listofcellnames,trialslist,timeint,sptimeint,blankID,0);
            save(analyzetpstack_getsavedfilename(ud.ds,stackname,dirname),'resps','listofcells','listofcellnames',...
                'dirname','refdirname','paramname','channel','trialslist','timeint','sptimeint','blankID','-mat');
            resps=tptuningcurve(fulldirname,channel,paramname,pixelarg,1,listofcellnames,trialslist,timeint,sptimeint,blankID,0);
        else,   % this is bad form, including a specific stim type in general code, but it is faster
            resps=tpTCDragoi(fulldirname,channel,paramname,pixelarg,1,listofcellnames,trialslist,timeint,sptimeint,blankID,~isempty(blankID));
            save(analyzetpstack_getsavedfilename(ud.ds,stackname,dirname),'resps','listofcells','listofcellnames',...
                'dirname','refdirname','paramname','channel','trialslist','timeint','sptimeint','blankID','-mat');
        end;
    case 'stimdirnameEdit',
	% EDITHERE for savename
        scratchname = fixpath(getscratchdirectory(ud.ds,1));
        dirname = get(ft(fig,'stimdirnameEdit'),'string');
        fname = stackname;
	try,
		g = analyzetpstack_loadsavedfilename(ds,stackname,dirname);
	catch, g = [];
	end;
        if ~isempty(g),
            fieldn = {'paramname','trialslist','timeint','sptimeint','blankID'};
            editfields = {'stimparamnameEdit','trialsEdit','timeintEdit','sptimeintEdit','BlankIDEdit'};
            forceUpdate = [0 1 1 1 1];
            for i=1:length(fieldn),
                if isfield(g,fieldn{i}),
                    myval = getfield(g,fieldn{i});
                    if ~isempty(myval),
                        if ~ischar(myval), myval = mat2str(myval); end;
                        set(ft(fig,editfields{i}),'string',myval);
                    elseif forceUpdate(i),
                        set(ft(fig,editfields{i}),'string','');
                    end;
                end;
            end;
        end;
    case 'DriftMenuPopup',
        v = get(ft(fig,'sliceList'),'value');
        dirname = trimws(ud.slicelist(v).dirname);
        inputs.dirname = dirname;
        inputs.ds = ud.ds;
        inputs.fullpathdirname = [getpathname(ud.ds) filesep inputs.dirname];
        inputs.refdirname = analyzetpstack_getrefdirname(ud,dirname);
        inputs.fullrefdirname = [fixpath(getpathname(ud.ds)) inputs.refdirname];
        inputs.channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
	inputs.xyoffset = analyzetpstack_getxyoffset(ud,inputs.dirname);
	inputs.refxyoffset = analyzetpstack_getxyoffset(ud,inputs.refdirname);

	[mn,mx,inputs.viewchannel,inputs.view,inputs.viewframe] = analyzetpstack_previewimage('GetSettings',[],fig);
	inputs.viewColorMinMax = [mn mx];
	inputs.analyzetpstack_handle = fig;

	global myinputs;
	myinputs = inputs;

	analyzetpstack_drift_devs_menu('handleclick',ft(fig,'DriftMenuPopup'),inputs);

    case 'checkDriftBt',
        dirname = get(ft(fig,'stimdirnameEdit'),'string');
        refdirname = analyzetpstack_getrefdirname(ud,dirname);
        fulldirname = [fixpath(getpathname(ud.ds)) dirname];
        val = get(ft(fig,'celllist'),'value');
        channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
        if strcmp(ud.celllist(val).dirname,refdirname)|strcmp(ud.celllist(val).dirname,dirname),
            ancestors = getallparents(ud,dirname);
            changes = getChanges(ud,val,dirname,ancestors);
            changes.dirname,
            if ~changes.present, errordlg(['Cell is not ''present'' in this recording.']); return;  end;
            centerloc = [mean(changes.xi)  mean(changes.yi)];
            roirect = round([ -20 -20 20 20] + [centerloc centerloc]);
            roiname=['cell ' int2str(ud.celllist(val).index) ' ref ' ud.celllist(val).dirname];
            myim=tpcheckroidrift(fulldirname,channel,roirect,changes.pixelinds,changes.xi-centerloc(1),...
                changes.yi-centerloc(2),roiname,1);
        else, errordlg(['Selected cell was not recorded in directory ' dirname '.']);
        end;
    case 'checkAlignmentBt',
        sliceind1 = get(ft(fig,'sliceList'),'value');
        currstr_ = get(ft(fig,'sliceList'),'string');
        if iscell(currstr_)&~isempty(currstr_),
		dirname1 = trimws(currstr_{sliceind1});  % currently selected
        else,
		disp(['No directories in list to examine.']);
		return;
        end;
        [sliceind2,okay]=listdlg('ListString',currstr_,'PromptString','Select dir to compare','SelectionMode','single');
        if isempty(sliceind2),
		return;
        else,
		dirname2 = trimws(currstr_{sliceind2});
        end;
        channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
        ancestors2 = getallparents(ud,dirname2);
        ancestors1 = getallparents(ud,dirname1);
        if isempty(intersect(dirname1,ancestors2)),
		error(['Error checking alignment: ' dirname1 ' and ' dirname2 ' are not recordings at the same place.']);
	end;
        refdirname = analyzetpstack_getrefdirname(ud,dirname1); % should be same for both
        [listofcells1,listofcellnames1,mycellstructs,changes1]=getcurrentcellschanges(ud,refdirname,dirname1,ancestors1);
        [listofcells2,listofcellnames2,mycellstructs,changes2]=getcurrentcellschanges(ud,refdirname,dirname2,ancestors2);
        [thelist,thelistinds1,thelistinds2] = intersect(listofcellnames1,listofcellnames2);
	pvimg1 = analyzetpstack_previewimage('GetPreviewImageData',[],fig,struct('channel',channel,'dirname',dirname1));
	pvimg2 = analyzetpstack_previewimage('GetPreviewImageData',[],fig,struct('channel',channel,'dirname',dirname2));
        try,
		drift1 = analyzetpstack_getdirdrift(ud,dirname1);
		xyoffset1 = analyzetpstack_getxyoffset(ud,dirname1);
		drift1 = drift1 + xyoffset1;
	catch,
		drift1 = [0 0];
	end;
        try,
		drift2 = analyzetpstack_getdirdrift(ud,dirname1);
		xyoffset2 = analyzetpstack_getxyoffset(ud,dirname2);
		drift2 = drift2 + xyoffset2;
	catch,
		drift2 = [0 0];
	end;
        plottpcellalignment(listofcellnames1(thelistinds1),listofcellnames2(thelistinds2),changes1(thelistinds1),changes2(thelistinds2),...
            pvimg1,pvimg2,dirname1,dirname2,drift1,drift2,3);
    case 'movieBt',
        dirname = get(ft(fig,'stimdirnameEdit'),'string');
        refdirname = analyzetpstack_getrefdirname(ud,dirname);
        fulldirname = [fixpath(getpathname(ud.ds)) dirname];
        trialsstr = get(ft(fig,'trialsEdit'),'string');
        if ~isempty(trialsstr), trialslist = eval(trialsstr); else, trialslist = []; end;
        stimstr = get(ft(fig,'movieStimsEdit'),'string');
        if ~isempty(stimstr), stimlist = eval(stimstr); else, stimlist = []; end;
        dF = get(ft(fig,'moviedFCB'),'value'); sorted=get(ft(fig,'movieSortCB'),'value');
        movfname = get(ft(fig,'movieFileEdit'),'string');
        channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
        fprintf('Preparing movie...will take several seconds...\n');
        M=tpmovie(fulldirname,channel,trialslist,stimlist,sorted,dF,8,[fixpath(getpathname(ud.ds)) movfname]);
    case 'QuickMapBt',
        dirname = get(ft(fig,'stimdirnameEdit'),'string');
        channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
        refdirname = analyzetpstack_getrefdirname(ud,dirname);
        fulldirname = [fixpath(getpathname(ud.ds)) dirname];
        fname = stackname;
        scratchname = fixpath(getscratchdirectory(ud.ds,1));
        try,
            g=analyzetpstack_loadsavedfile(ds,stackname,dirname);
        catch,
            errordlg(['Can''t open analysis file.  Please analyze data first.']);
            error(['Can''t open analysis file.  Please analyze data first.']);
        end;
        try,
		thresh = str2num(get(ft(fig,'mapthreshEdit'),'string'));
        catch,
		errordlg(['Syntax error in map threshold: ' get(ft(fig,'mapthreshEdit'),'string') '.']);
		error(['Syntax error in map threshold: ' get(ft(fig,'mapthreshEdit'),'string') '.']);
        end;
        im=tpquickmap(fulldirname,channel,g.resps,g.listofcells,1,'threshold',thresh);
    case 'QuickPSTHBt',
        dirname = get(ft(fig,'stimdirnameEdit'),'string');
        refdirname = analyzetpstack_getrefdirname(ud,dirname);
        fulldirname = [fixpath(getpathname(ud.ds)) dirname];
        ancestors = getallparents(ud,dirname);
        [listofcells,listofcellnames]=getcurrentcellschanges(ud,refdirname,dirname,ancestors);
        fname = stackname; scratchname = fixpath(getscratchdirectory(ud.ds,1));
        needtorun = 1;
        channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
	try,
		g = analyzetpstack_loadrawfile(ud.ds,stackname,dirname);
            	needtorun = ~(g.listofcellnames==listofcellnames);
        end;
        if needtorun,
            [data,t] = tpreaddata(fulldirname,[-Inf Inf],listofcells,1,channel);
            save(analyzetpstack_getrawname(ud.ds,stackname,dirname),'data','t','listofcells','listofcellnames','-mat');
            pixelarg = listofcells;
        else,
            pixelarg = analyzetpstack_loadrawfile(ud.ds,stackname,dirname);
        end;
        binsize = eval(get(ft(fig,'QuickPSTHEdit'),'string'));
        plotit = 1 + get(ft(fig,'QuickPSTHCB'),'value');
        fprintf('Analyzing...will take a few seconds...\n');
        global mydata myt myavg mybins;
        [mydata,myt,myavg,mybins]=tpquickpsthsliding(fulldirname,channel,[],pixelarg,plotit,listofcellnames,binsize,0.1,0,[]);
    case 'correctDriftBt', % depricated, should be removed soon
	dirname = get(ft(fig,'stimdirnameEdit'),'string');
	refdirname = analyzetpstack_getrefdirname(ud,dirname),
	fulldirname = [fixpath(getpathname(ud.ds)) dirname];
	fullrefdirname = [fixpath(getpathname(ud.ds)) refdirname];
	channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
        prompt = {'Search space in x:','Search space in y:','Search space to match initial reference in x:','Search space to match initial reference in y:',...
            'Correct each N frames:','Average N frames together','Normalize images first?','Use brightest parts only?','Ignore pixels above X percentile (100=none)?','Only correct within this directory (I''ll manually align across directories)'};
        name = 'Parameters for drift correction...';
        numlines = 1;
        defaultanswer = {'[-6:2:6]','[-6:2:6]','[-100:10:100]','[-100:10:100]','10','5','1','1','100','0'};
        answ = inputdlg(prompt,name,numlines,defaultanswer);
        if isempty(answ), return; end;
        searchx = eval(answ{1}); searchy = eval(answ{2}); refsearchx = eval(answ{3}); refsearchy = eval(answ{4}); howoften = eval(answ{5}); howmany = eval(answ{6});
        brightnesscorrect = eval(answ{7}); roicorrect = eval(answ{8}); brightnessartifact = eval(answ{9});
        onlylocal = eval(answ{10});
        if onlylocal, myfullrefdirname = fulldirname; else, myfullrefdirname = fullrefdirname; end;
		dr=tpdriftcheck(fulldirname,channel,searchx,searchy,myfullrefdirname,refsearchx,refsearchy,howoften,howmany,brightnesscorrect,roicorrect,0,brightnessartifact,1,1);
        if ~strcmp(fulldirname,fullrefdirname),
            str = get(ft(fig,'sliceList'),'string');
            foundit = 0;
            for i=1:length(str),
                if strcmp(str{i},refdirname),
                    foundit = i; break;
                end;
            end;
            if foundit > 0,
                set(ft(fig,'sliceList'),'value',foundit);
                analyzetpstack_slicelist('UpdateSliceDisplay',[],fig);
            end;
        end;
    case 'shiftDriftBt',  % depricated, leaving here in case of disaster but should be removed
        warndlg('Warning: you should use CheckDrift on a bright cell to check the results of your manual shifts over the duration of the recording.  Even if the shift is good at the beginning of the trial, it may slip later on.  It is recommended that you first try adjusting the drift correct parameters and correcting drift again before resorting to manually shifting.','Warning');
        dirname = get(ft(fig,'stimdirnameEdit'),'string');
        fulldirname = [fixpath(getpathname(ud.ds)) dirname];
        refdirname = analyzetpstack_getrefdirname(ud,dirname),
        fullrefdirname = [fixpath(getpathname(ud.ds)) refdirname];
        tpdirs = tpdirnames(fulldirname);
        prompt = {'Shift in x:','Shift in y:'};
        name = 'Parameters for manual drift shift...';
        numlines = 1;
        defaultanswer = {'0','0'};
        answ = inputdlg(prompt,name,numlines,defaultanswer);
        if isempty(answ), return; end;
        for i=1:length(tpdirs), shiftdriftcorrect(tpdirs{i},eval(answ{1}),eval(answ{2})); end;
        if ~strcmp(fulldirname,fullrefdirname),
            str = get(ft(fig,'sliceList'),'string');
            foundit = 0;
            for i=1:length(str),
                if strcmp(str{i},refdirname),
                    foundit = i; break;
                end;
            end;
            if foundit > 0,
                set(ft(fig,'sliceList'),'value',foundit);
                analyzetpstack_slicelist('UpdateSliceDisplay',[],fig);
            end;
        end;
    case 'ImageMathBt',
        str = get(ft(fig,'ImageMathEdit'),'string');
        op_minus = find(str=='-'); op_plus = find(str=='+');
        op_mult = find(str=='*'); op_divide = find(str=='/');
        op_loc = [ op_minus op_plus op_mult op_divide];
        op = str(op_loc);
        stim1 = str2num(str(1:op_loc-1)); stim2 = str2num(str(op_loc+1:end));
        dirname = get(ft(fig,'stimdirnameEdit'),'string');
        fulldirname = [fixpath(getpathname(ud.ds)) dirname];
        fprintf('Analyzing...will take a few seconds...\n');
        channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
        [r,im1,im2]=tpimagemath(fulldirname,channel,stim1,stim2,op,1,[dirname ' | ' str]);
        imagedisplay(im1,'Title',int2str(stim1)); imagedisplay(im2,'Title',int2str(stim2));
    case 'singleCondBt',
        dirname = get(ft(fig,'stimdirnameEdit'),'string');
        refdirname = analyzetpstack_getrefdirname(ud,dirname);
        fulldirname = [fixpath(getpathname(ud.ds)) dirname];
        trialsstr = get(ft(fig,'trialsEdit'),'string');
        if ~isempty(trialsstr), trialslist = eval(trialsstr); else, trialslist = []; end;
        timeintstr = get(ft(fig,'timeintEdit'),'string');
        if ~isempty(timeintstr), timeint= eval(timeintstr); else, timeint= []; end;
        sptimeintstr = get(ft(fig,'sptimeintEdit'),'string');
        if ~isempty(sptimeintstr), sptimeint= eval(sptimeintstr); else, sptimeint= []; end;
        fprintf('Analyzing...will take a few seconds...\n');
        channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
        [r,indimages]=tpsinglecondition(fulldirname,channel,trialslist,timeint,sptimeint,1,dirname);
        fname = stackname; scratchname = fixpath(getscratchdirectory(ud.ds,1));
        filename = [scratchname fname '_' dirname '_SC'];
        save(filename,'r','indimages','-mat');
    case 'AddDBBt',
        ud.ds = dirstruct(getpathname(ud.ds));
        sv = get(ft(fig,'sliceList'),'value');
        dirname = trimws(ud.slicelist(sv).dirname);
        [listofcells,listofcellnames,cellstructs]=getcurrentcells(ud,dirname);
        refs = getnamerefs(ud.ds,dirname);
        foundIt=0;
        for i=1:length(refs), if strcmp(refs(i).name,'tp'), foundIt = i; break; end; end;
        depth=num2str(get(ft(fig,'depthEdit'),'string'));
        xyoffset = analyzetpstack_getxyoffset(ud,dirname);
        if foundIt>0,
            analyzetpstack_addtotpdatabase(ud.ds,refs(foundIt),cellstructs,listofcellnames,'analyzetpstack name',stackname,'depth',depth,'xyoffset',xyoffset);
        else,
            errordlg(['Could not find two-photon reference for directory ' dirname '.']);
        end;
    case 'saveBt',
        fname = stackname;
        scratchname = fixpath(getscratchdirectory(ud.ds,1));
        celllist = ud.celllist;
        slicelist = ud.slicelist;
        changes = {};
        if isfield(ud.celldrawinfo,'changes'), changes = ud.celldrawinfo.changes; end;
        tpassociatelistglobals;
        assoclist=tpassociatelist;
        if exist([scratchname fname '.stack']),
            answer = questdlg('File exists...overwrite?',...
                'File exists...overwrite?','OK','Cancel','Cancel');
            if strcmp(answer,'OK'),
                save([scratchname fname '.stack'],'celllist','slicelist',...
                    'changes','assoclist','-mat');
                    %'previewimage','changes','assoclist','previewparams','-mat');
            end;
        else,
            save([scratchname fname '.stack'],'celllist','slicelist','changes','assoclist','-mat');
        end;
    case 'loadBt',
	fname = stackname;
	scratchname = fixpath(getscratchdirectory(ud.ds,1));
	if exist([scratchname fname '.stack']),
		figure(fig);
		clf;
		analyzetpstack('NewWindow',[],fig);
		set(ft(fig,'stacknameEdit'),'string',fname);
		ud = get(fig,'userdata');
		g = load([scratchname fname '.stack'],'-mat');
		% update the tpassociatlist
		if isfield(g,'assoclist'),
			tpassociatelistglobals;
			needtowarnassoc=0;
			for j=1:length(g.assoclist),
				gotmatch = 0;
				for i=1:length(tpassociatelist),
					if strcmp(tpassociatelist(i).type,g.assoclist(j).type),
						gotmatch=1;needtowarnassoc=1;
						tpassociatelist(i) = g.assoclist(j);
						break;
					end;
				end;
				if ~gotmatch, tpassociatelist(end+1) = g.assoclist(j); end;
			end;
			if needtowarnassoc, warndlg('Some changes were made to the experiment associate list.  Check to make sure current values are correct.','Warning'); end;
		end;
		% update slicelist version if necessary
		if length(g.slicelist)>=1,
			if ~isfield(g.slicelist(1),'xyoffset'),
				newlist = g.slicelist(1); newlist.xyoffset = [0 0];newlist=newlist([]);
				for i=1:length(g.slicelist),
					newentry = g.slicelist(i);
					newentry.xyoffset = [0 0];
					newlist(i) = newentry;
				end;
				g.slicelist = newlist;
			end;
		end;
		% update celllist version if necessary
		if length(g.celllist)>1,
			if ~isfield(g.celllist(1),'type'), % then type is cell and label is Oregon green
				newlist=g.celllist(1);newlist.type='';newlist.labels={''};newlist=newlist([]);
				for i=1:length(g.celllist),
					newcell = g.celllist(i);
					newcell.type = 'cell'; newcell.labels={'Oregon green'};
					newlist(i) = newcell;
				end;
				g.celllist = newlist;
			end;
		end;
		ud.celllist=g.celllist;ud.slicelist=g.slicelist;
		analyzetpstack_previewimage('InitializePreviewImageVars',[],fig);
		set(fig,'userdata',ud);
		analyzetpstack_slicelist('UpdateSliceDisplay',[],fig);
		else, errordlg(['File ' scratchname fname '.stack does not exist.']);
        end;
        analyzetpstack_slicelist('UpdateSliceDisplay',[],fig);
	analyzetpstack('UpdateCellList',[],fig);
    otherwise,
        disp(['Unhandled command: ' command '.']);
end;

% speciality functions


function obj = ft(fig, name)
obj = findobj(fig,'Tag',name);

function [listofcells,listofcellnames,cellstructs] = getcurrentcells(ud,refdirname)
listofcells = {}; listofcellnames = {};
cellstructs = analyzetpstack_emptycellrec; cellstructs = cellstructs([]);
for i=1:length(ud.celllist),
    if strcmp(ud.celllist(i).dirname,refdirname),
        listofcells{end+1} = ud.celllist(i).pixelinds;
        listofcellnames{end+1}=['cell ' int2str(ud.celllist(i).index) ' ref ' ud.celllist(i).dirname];
        cellstructs = [cellstructs ud.celllist(i)];
    end;
end;

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

function setChanges(ud,fig,i,newchanges)
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

function [slicestructupdate] = updatecelldraw(ud,i,slicestruct,currdir,numpreviewframes)
% make a lookup table for slicelist, drift, and ancestors, if it doesn't
% already exist
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
		slicestruct.sliceancestorlookup=setfield(slicestruct.sliceancestorlookup,cleandirname, getallparents(ud,cleandirname));
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
	changes = getChanges(ud,i,currdir,ancestors);
	if changes.present,
		mycolor = [0 0 1];
	else,
		mycolor = [ 1 0.5 0.5];
	end;
else
	drift = getfield(slicestructupdate.slicedriftlookup, ud.celllist(i).dirname);
	xyoffset = getfield(slicestructupdate.slicexyoffsetlookup, ud.celllist(i).dirname);
	total_drift = drift + xyoffset;
	changes = getChanges(ud,i,ud.celllist(i).dirname,[]);
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

function zoomtogcb(obj,evo)
if get(obj,'Value')==1
    % first turn off pan, and unclick toggle
    pan off
    btns=findobj(gcf,'Style','togglebutton');
    for i=1:length(btns)
        if btns(i)~=obj
            set(btns(i),'Value',0)
        end
    end
    %now turn zoom on
    zoom on
end
if get(obj,'Value')==0
    zoom off
end

function pantogcb(obj,evo)
if get(obj,'Value')==1
    % first turn off zoom, and unclick toggle
    zoom off
    btns=findobj(gcf,'Style','togglebutton');
    for i=1:length(btns)
        if btns(i)~=obj
            set(btns(i),'Value',0)
        end
    end
    %now turn pan on
    pan on
end
if get(obj,'Value')==0
    pan off
end

function hotkeyreader(obj,evo,fig)
switch evo.Key
    case 'p'
        if strcmp(get(ft(fig,'presentCB'),'enable'),'on')
            if get(ft(fig,'presentCB'),'value')==1;
                set(ft(fig,'presentCB'),'value',0);
            else set(ft(fig,'presentCB'),'value',1);
            end
            analyzetpstack('presentCB',[],fig);
        end
    case 'backspace'
        analyzetpstack('deletecellBt',[],fig);
    case 'd'
        analyzetpstack('drawnewballBt',[],fig);
    case 'space'
            if get(ft(fig,'DrawCellsCB'),'value')==1;
                set(ft(fig,'DrawCellsCB'),'value',0);
            else set(ft(fig,'DrawCellsCB'),'value',1);
            end
        analyzetpstack('DrawCellsCB',[],fig);
    case 'm'
        analyzetpstack('moveCellBt',[],fig);
end
