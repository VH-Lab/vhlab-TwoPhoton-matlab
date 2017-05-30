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

NUMPREVIEWFRAMES = 30;

if nargin==2, % command is actually experiment directoryar name
	dirname = command;
	command = 'NewWindow';
	ud.ds = dirstruct(dirname);
	fig = figure;
	set(fig,'Tag','analyzetpstack','position',[381 217 630 650]);
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

switch command,
	case 'NewWindow',
		button.Units = 'pixels';
		button.BackgroundColor = [0.8 0.8 0.8];
		button.HorizontalAlignment = 'center';
		button.Callback = 'genercallback';
		txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8];
		txt.fontsize = 12; txt.fontweight = 'normal';
		txt.HorizontalAlignment = 'center';txt.Style='text';
		edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';
		popup = txt; popup.style = 'popupmenu';
		cb = txt; cb.Style = 'Checkbox'; cb.Callback = 'genercallback';
		cb.fontsize = 12;

		sh=50+10;
		axes('units','pixels','position',[30 280+sh 300 300],'Tag','tpaxes');
		sh=sh+40;
		uicontrol(txt,'position',[05 200+sh 80 20],'String','Color min','horizontalalignment','center');
		uicontrol(txt,'position',[160 200+sh 80 20],'String','Color max','horizontalalignment','center');
		uicontrol(popup,'position',[05 180+sh 100 20],'String',...
			{'Channel 1','Channel 2','Channel 3','Channel 4'}','value',1,...
				'horizontalalignment','center','callback','genercallback','tag','channelPopup');
		uicontrol(edit,'position',[85 200+2+sh 70 20],'String','0','horizontalalignment','center',...
			'Tag','ColorMinEdit','callback','genercallback');
		uicontrol(edit,'position',[245 200+2+sh 70 20],'String','1000','horizontalalignment','center',...
			'Tag','ColorMaxEdit','callback','genercallback');
		sh=sh-30;

		sh=sh+10;
		uicontrol('Units','pixels','position',[10 10+sh 200 160],...
			'Style','list','BackgroundColor',[1 1 1],'Tag','celllist',...
			'Callback','genercallback');
		uicontrol(txt,'position',[10 170+sh 200 20],'String','Cells: id#|stack#');
		uicontrol(button,'position',[220 162+sh 110 20],'String','Auto draw cells',...
			'Tag','autoDrawCellsBt','Enable','on');
		uicontrol(button,'position',[220 142+sh 110 20],'String','Draw new cell',...
			'Tag','drawnewBt');
		uicontrol(button,'position',[220 120+sh 110 20],'String','Draw circles until <return>',...
			'Tag','drawnewballBt','fontsize',9);
		uicontrol(txt,'position',[220 100-2+sh 50 20],'String','Dia.:');
		uicontrol(edit,'position',[220+50 100+sh 40 20],'String','12','Tag','newballdiameterEdit');
		uicontrol(button,'position',[220 80+sh 110 20],'String','Redraw cell','Tag','redrawCellBt');
		uicontrol(button,'position',[220 60+sh 110 20],'String','Move cell','Tag','moveCellBt');
		uicontrol(cb, 'position', [220 40+sh 110 20],'String','Present','value',1,...
			'Tag','presentCB','callback','genercallback');
		uicontrol(popup,'position',[220 20+sh 110 20],'String',tpstacktypes,'Tag','cellTypePopup','callback','genercallback');
		uicontrol(button,'position',[220 -40+sh 110 20],'String','Delete cell','Tag','deletecellBt');
		uicontrol(txt,'position',[10 -5+sh 200 20],'String','Cell labels:','value',1);
		uicontrol('Units','pixels','position',[10 -70+sh 200 70],...
			'Style','list','BackgroundColor',[1 1 1],'Tag','labelList',...
			'Callback','genercallback','string',tpstacklabels,'Max',2);
		sh=sh-30;

		sh = sh+50-10;
		uicontrol(txt,'position',[333 528+sh 80 20],'String','Stack name',...
			'horizontalalignment','left');
		uicontrol(edit,'position',[425 530+sh 80 20],'String',stackname,'Tag','stacknameEdit');
		uicontrol(button,'position',[515 530+sh 30 20],'String','Load','Tag','loadBt');
		uicontrol(button,'position',[545 530+sh 30 20],'String','Save','Tag','saveBt');
		uicontrol(button,'position',[500 500+sh 70 20],'String','Add new slice','Tag','addsliceBt');
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
		uicontrol(button,'position',[340 420+sh 100 20],'String','Remove slice','Tag','RemoveSliceBt');
		
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
		uicontrol(button,'position',[340 -25-15+sh 100 20],'String','Correct drift','Tag','correctDriftBt');
		uicontrol(button,'position',[445 -25-15+sh 100 20],'String','Check drift','Tag','checkDriftBt');
        uicontrol(button,'position',[550 -25-15+sh 60 20],'String','Man.shift','tag','shiftDriftBt');
        %uicontrol(button,'position',[340 -25-25-15+sh 100 20],'String','Baseline','Tag','baselineBt');  % obsolete
		
		% now make data structures
		slicelist = emptyslicerec; slicelist = slicelist([]);
		celllist = emptycellrec; celllist = celllist([]);
		previewimage = {}; previewdir = []; previewchannel = 1;
		ud.slicelist = slicelist; ud.celllist = celllist;
		ud.previewimage = previewimage; ud.previewdir = [];
		ud.previewimage2 = {}; ud.previewimage3 = {}; ud.previewimage4 = {};
        ud.previewparams = {};
        ud.previewparams2 = {};
        ud.previewparams3 = {};
        ud.previewparams4 = {};
		ud.previewim = []; ud.previewchannel = 1;
		ud.celldrawinfo.dirname = [];
		ud.celldrawinfo.h = [];
		ud.celldrawinfo.t = [];
        ud.linescanpreview = [];


		set(fig,'userdata',ud);
	case 'UpdateSliceDisplay',
		v_ = get(ft(fig,'sliceList'),'value');
		currstr_ = get(ft(fig,'sliceList'),'string');
		if iscell(currstr_)&~isempty(currstr_), selDir = trimws(currstr_{v_});  % currently selected
		else, selDir = {};
		end;
		inds = [];
		newlist = {};
		currInds = 1:length(ud.slicelist);
		while ~isempty(currInds),
			parentdir = getrefdirname(ud,ud.slicelist(currInds(1)).dirname);
			if strcmp(parentdir,ud.slicelist(currInds(1)).dirname),  % if it is a parent directory, find all its kids
				newlist{end+1} = parentdir;
				inds(end+1) = currInds(1);
				currInds = setdiff(currInds,currInds(1));  % we will include this as a parent
				kids = [];
				for j=currInds,
					myparent = getrefdirname(ud,ud.slicelist(j).dirname);
					if strcmp(parentdir,myparent),
						kids(end+1) = j;
						newlist{end+1} = ['    ' ud.slicelist(j).dirname];
						inds(end+1) = j;
					end;
				end;
				currInds = setdiff(currInds,kids);
			end;
		end;
		littlelist = {};
		for i=1:length(newlist), littlelist{i} = trimws(newlist{i}); end;
		[c,ia]=intersect(littlelist,selDir);
		if ~isempty(c), v = ia(1); else, v = 1; end;
		% now to reshuffle the slicelists
		ud.slicelist = ud.slicelist(inds);
		ud.previewimage = ud.previewimage(inds);
		ud.previewparams = ud.previewparams(inds);        
		if length(ud.previewimage2)<length(inds),
			for i=max([1 length(ud.previewimage2)]):length(inds), ud.previewimage2{i} = []; ud.previewparams2{i}=[]; end;
		end;
		if length(ud.previewimage3)<length(inds),
			for i=max([1 length(ud.previewimage3)]):length(inds), ud.previewimage3{i} = []; ud.previewparams3{i}=[]; end;
		end;
		if length(ud.previewimage4)<length(inds),
			for i=max([1 length(ud.previewimage4)]):length(inds), ud.previewimage4{i} = []; ud.previewparams4{i}=[]; end;
		end;
		ud.previewimage2 = ud.previewimage2(inds);
		ud.previewimage3 = ud.previewimage3(inds);
		ud.previewimage4 = ud.previewimage4(inds);
		ud.previewparams2 = ud.previewparams2(inds);
		ud.previewparams3 = ud.previewparams3(inds);
		ud.previewparams4 = ud.previewparams4(inds);
		set(fig,'userdata',ud);
		set(ft(fig,'sliceList'),'string',newlist,'value',v);
		if length(ud.slicelist)~=0,
			set(ft(fig,'DrawLinescansCB'),'value',ud.slicelist(v).analyzecells);
			set(ft(fig,'DrawCellsCB'),'value',ud.slicelist(v).drawcells);
			set(ft(fig,'depthEdit'),'string',num2str(ud.slicelist(v).depth));
			set(ft(fig,'sliceOffsetEdit'),'string',['[' num2str(ud.slicelist(v).xyoffset) ']']);
			parentdir = getrefdirname(ud,trimws(ud.slicelist(v).dirname));
			if ~strcmp(parentdir,trimws(ud.slicelist(v).dirname)),
				set(ft(fig,'sliceOffsetEdit'),'visible','off');
				set(ft(fig,'sliceOffsetText'),'visible','off');
			else,
				set(ft(fig,'sliceOffsetEdit'),'visible','on');
				set(ft(fig,'sliceOffsetText'),'visible','on');
			end;
		end;
		analyzetpstack('UpdatePreviewImage',[],fig);
		analyzetpstack('UpdateCellImage',[],fig);
		analyzetpstack('UpdateCellLabels',[],fig);
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
		analyzetpstack('UpdatePreviewImage',[],fig);
	case 'UpdatePreviewImage', % updates preview image if necessary
		v = get(ft(fig,'sliceList'),'value');
		dirname = trimws(ud.slicelist(v).dirname);
		channel = get(ft(fig,'channelPopup'),'value');
        if ishandle(ud.linescanpreview),
                if ud.slicelist(v).analyzecells,  set(ud.linescanpreview,'visible', 'on'); 
                else, set(ud.linescanpreview,'visible','off');
                end;
        end;
		if ~strcmp(dirname,ud.previewdir)|channel~=ud.previewchannel,  % we need to update
			if ishandle(ud.previewim), delete(ud.previewim); end;
            if isfield(ud,'linescanpreview'), 
                if ishandle(ud.linescanpreview), delete(ud.linescanpreview); end;
            end;
			ud.previewdir = dirname;
			axes(ft(fig,'tpaxes'));
			try, mn=str2num(get(ft(fig,'ColorMinEdit'),'string'));
			catch, errordlg(['Syntax error in colormin.']); mn=0;
			end;
			try, mx=str2num(get(ft(fig,'ColorMaxEdit'),'string'));
			catch, errordlg(['Syntax error in colormax.']); mx=0;
			end;
			if channel==1,
				ud.previewim=image(rescale((ud.previewimage{v}),[mn mx],[0 255]));
				xyoffset = getxyoffset(ud,dirname);
				set(ud.previewim,'xdata',get(ud.previewim,'xdata')-xyoffset(1),'ydata',get(ud.previewim,'ydata')-xyoffset(2));
                if isfield(ud.previewparams{v},'Type')
                    if strcmp(ud.previewparams{v}.Type,'Linescan'),
                        hold on;
                        ud.linescanpreview=plot(ud.previewparams{v}.Linescanpoints(:,1)-xyoffset(1),ud.previewparams{v}.Linescanpoints(:,2)-xyoffset(1),'y','linewidth',1);
                    end;
                end;
                
			else,
				eval(['b=length(ud.previewimage' int2str(channel) ')<v;']);
				eval(['if ~b, b=isempty(ud.previewimage' int2str(channel) '{v});end;']);
				if b,
					try,
						sc = getscratchdirectory(ud.ds,1);
						pvfilename = [sc filesep 'preview_' dirname '_ch' int2str(channel) '.mat'];
						if exist(pvfilename)==2,
							load(pvfilename);
						else,
				          	[pvimg,pvparams]=tppreview([fixpath(getpathname(ud.ds)) filesep dirname],NUMPREVIEWFRAMES,1,channel);
							save(pvfilename,'pvimg','pvparams');
						end;
						eval(['ud.previewimage' int2str(channel) '{v} = pvimg;']);
                        eval(['ud.previewparams' int2str(channel) '{v} = pvparams;']);
					catch, disp(['No data on channel ' int2str(channel) '.']);
					end;
				end;
				eval(['b=length(ud.previewimage' int2str(channel) ')<v;']);
				eval(['if ~b, b=isempty(ud.previewimage' int2str(channel) '{v});end;']);
				if ~b,
					xyoffset = getxyoffset(ud,dirname);
                    eval(['ud.previewim=image(rescale(ud.previewimage' int2str(channel) '{v},[mn mx],[0 255]));']);
                    if isfield(ud.previewparams{v},'Type')
                        if strcmp(ud.previewparams{v},'Linescan'),
                            hold on;
                            ud.linescanpreview=plot(ud.previewparams{v}.Linescanpoints(:,1)-xyoffset(1),ud.previewparams{v}.Linescanpoints(:,2)-xyoffset(1),'g','linewidth',1);
                        end;
                    end;
					set(ud.previewim,'xdata',get(ud.previewim,'xdata')-xyoffset(1),'ydata',get(ud.previewim,'ydata')-xyoffset(2));
				else, % user selected bad channel, have to get out of this gracefully
					set(ft(fig,'channelPopup'),'value',ud.previewchannel);
					ud.previewchannel = 0; 
					set(fig,'userdata',ud);
					analyzetpstack('UpdatePreviewImage',[],fig);
					return;
				end;
			end;
			ud.previewchannel = channel;
			colormap(gray(256));
			set(gca,'tag','tpaxes');
			ch = get(gca,'children');
			ind = find(ch==ud.previewim);
			if length(ch)>1,% make on bottom
				ch = cat(1,ch(1:ind-1),ch(ind+1:end),ch(ind));
				set(gca,'children',ch);
			end;
			ch = get(gca,'children');
            if ishandle(ud.linescanpreview),
                ind = find(ch==ud.linescanpreview);
                if ishandle(ud.linescanpreview)&length(ch)>1,% make on top
                    ch = cat(1,ch(ind),ch(1:ind-1),ch(ind+1:end));
                    if ud.slicelist(v).analyzecells,  set(ch(1),'visible', 'on'); 
                    else, set(ch(1),'visible','off');
                    end;
                    set(gca,'children',ch);
                end;
            end;
			set(fig,'userdata',ud);
		end;
	case 'UpdateCellImage',
		cv = get(ft(fig,'celllist'),'value');
		sv = get(ft(fig,'sliceList'),'value');
		newdir = get(ft(fig,'sliceList'),'string');
		newdir = trimws(newdir{sv});
		parentdir=getrefdirname(ud,newdir);  % is there a parent directory?
		ancestors=getallparents(ud,newdir);  % is there a parent directory?
			%bg color is red, fg is blue, highlighted is yellow
		if length(ud.celldrawinfo.h)~=length(ud.celllist),
			% might need to draw cells
			% we do when we are drawing for first time
                        % or if we are adding a cell
			drift = getcurrentdirdrift(ud,newdir,NUMPREVIEWFRAMES);
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
				xi = ud.celllist(i).xi; xi(end+1) = xi(1);
				yi = ud.celllist(i).yi; yi(end+1) = yi(1);
				ud.celldrawinfo.h(end+1) = plot(xi-drift(1),yi-drift(2),'linewidth',2);
				ud.celldrawinfo.t(end+1) = text(mean(xi)-drift(1),mean(yi)-drift(2),...
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
		parentdir=getrefdirname(ud,newdir);  % is there a parent directory?
		if isempty(parentdir)|strcmp(parentdir,newdir)|strcmp(newdir,ud.celllist(v).dirname),
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
		analyzetpstack('UpdatePreviewImage',[],fig);        
	case 'sliceList',
		analyzetpstack('UpdateSliceDisplay',[],fig);
	case 'celllist',
		analyzetpstack('UpdateCellLabels',[],fig);
		analyzetpstack('UpdateCellImage',[],fig);
	case 'presentCB',
		v = get(ft(fig,'celllist'),'value');
		sv = get(ft(fig,'sliceList'),'value'); currdir = get(ft(fig,'sliceList'),'string'); currdir = trimws(currdir{sv});
		parentdir=getrefdirname(ud,currdir);  % is there a parent directory?
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
		sz = size(get(ud.previewim,'CData'));
		[blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));
		drift = getcurrentdirdrift(ud, currdir, NUMPREVIEWFRAMES);
		if cellisactualcell,
			cr = ud.celllist(v);
			cr.xi = ud.celllist(v).xi - mean(ud.celllist(v).xi) + x + drift(1) ;
			cr.yi = ud.celllist(v).yi - mean(ud.celllist(v).yi) + y + drift(2);
            bw = inpolygon(blankprev_x,blankprev_y,cr.xi,cr.yi);
			cr.pixelinds = find(bw);
			ud.celllist(v) = cr;
			if 0,
				im0 = zeros(size(get(ud.previewim,'CData')));
				figure;
				im0(bw) = 255;
				image(im0);
			end;
		else, % 
			changes = getChanges(ud,v,currdir,ancestors);
			changes.xi = ud.celllist(v).xi+drift(1)-mean(ud.celllist(v).xi)+x;
			changes.yi = ud.celllist(v).yi+drift(2)-mean(ud.celllist(v).yi)+y;
            bw = inpolygon(blankprev_x,blankprev_y,changes.xi,changes.yi);
			changes.pixelinds = find(bw);
            changes.dirname = currdir;
			if 0,
				im0 = zeros(size(get(ud.previewim,'CData')));
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
		drift = getcurrentdirdrift(ud, currdir, NUMPREVIEWFRAMES);
		if cellisactualcell,
			cr = ud.celllist(v);
			cr.xi = xi+drift(1); cr.yi = yi+drift(2);
			cr.pixelinds = find(bw);
			ud.celllist(v) = cr;
			if 0,
				im0 = zeros(size(get(ud.previewim,'CData')));
				figure;
				im0(bw) = 255;
				image(im0);
			end;
		else, % 
			sz = size(get(ud.previewim,'CData'));
			[blankprev_x,blankprev_y] = meshgrid(1:sz(2),1:sz(1));
			changes = getChanges(ud,v,currdir,ancestors);
			changes.xi = xi+drift(1);
			changes.yi = yi+drift(2);
            bw = inpolygon(blankprev_x,blankprev_y,changes.xi,changes.yi);
			changes.pixelinds = find(bw);
            changes.dirname = currdir;
			if 0,
				im0 = zeros(size(get(ud.previewim,'CData')));
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
	case 'addsliceBt',
		ud.ds = dirstruct(getpathname(ud.ds));
		dirlist = getalltests(ud.ds);
		[s,ok] = listdlg('ListString',dirlist);
		if ok==1,
			newslice = emptyslicerec;
			newslice.dirname = dirlist{s};
			numFrames = NUMPREVIEWFRAMES; channel = 1;
			sc = getscratchdirectory(ud.ds,1);
			pvfilename = [sc filesep 'preview_' newslice.dirname '_ch1.mat'];
			% see if we have a preview image already computed, and if not, compute it and save it 
			if exist(pvfilename)==2,
				load(pvfilename);
                if ~exist('params','var'), 
                    [pvimg,params]=tppreview(fullfile(fixpath(getpathname(ud.ds)),newslice.dirname),...
                        numFrames,1,channel);
                    save(pvfilename,'pvimg','params');
                end;
			else,
				[pvimg,params]=tppreview(fullfile(fixpath(getpathname(ud.ds)),newslice.dirname),...
					numFrames,1,channel);
				save(pvfilename,'pvimg','params');
			end;
			ud.previewimage = cat(1,ud.previewimage,{pvimg});
			ud.previewparams = cat(1,ud.previewparams,{params});            
			ud.slicelist = [ud.slicelist newslice];
		end;
		set(fig,'userdata',ud);
		analyzetpstack('UpdateSliceDisplay',[],fig);
	case 'RemoveSliceBt',
		v = get(ft(fig,'sliceList'),'value');
		dirname = get(ft(fig,'sliceList'),'string');
		dirname = trimws(dirname{v}),
		ud.slicelist = [ud.slicelist(1:(v-1)) ud.slicelist((v+1):end)];
		ud.previewimage = [ud.previewimage(1:(v-1));ud.previewimage((v+1):end)];
		cellinds = []; celldel = [];
		for i=1:length(ud.celllist),
			if ~strcmp(ud.celllist(i).dirname,dirname),
				cellinds(end+1) = i;
			else, celldel(end+1) = i;
			end;
		end;
		ud.celllist = ud.celllist(cellinds);
		delete(ud.celldrawinfo.h(celldel)); delete(ud.celldrawinfo.t(celldel)); 
		ud.celldrawinfo.h=ud.celldrawinfo.h(cellinds);
		ud.celldrawinfo.t=ud.celldrawinfo.t(cellinds);
		set(fig,'userdata',ud);
		analyzetpstack('UpdateSliceDisplay',[],fig);
		analyzetpstack('UpdateCellList',[],fig);
    case 'autoDrawCellsBt',
		v = get(ft(fig,'sliceList'),'value');
		dirname = trimws(ud.slicelist(v).dirname);
        [dummy,params] = find_cellsMM;
        % now autofind the cells
        cell_list=find_cellsMM(ud.previewimage{v},params);
   		typestr = get(ft(fig,'cellTypePopup'),'string');
		labelstr = get(ft(fig,'labelList'),'string');
        for i=1:length(cell_list),
            newcell = emptycellrec;
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
		dr = getcurrentdirdrift(ud,dirname, NUMPREVIEWFRAMES);
		figure(fig);
		axes(ft(fig,'tpaxes'));
		zoom off;
		[bw,xi,yi]=roipoly();
		newcell=emptycellrec;
		newcell.dirname = dirname;
		newcell.pixelinds = find(bw);
		newcell.xi = xi+dr(1); newcell.yi = yi+dr(2);
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
	case 'drawnewballBt',
		v = get(ft(fig,'sliceList'),'value');
		dirname = trimws(ud.slicelist(v).dirname);
		dr = getcurrentdirdrift(ud,dirname, NUMPREVIEWFRAMES);
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
			xi = [xi_ xi_(end:-1:1)]+x+dr(1);
			yi = [yi_p yi_m(end:-1:1)]+y+dr(2);
			bw = inpolygon(blankprev_x,blankprev_y,xi,yi);
			%figure; image(bw*255); colormap(gray(256)); figure(fig);
			%hold on; plot(xi,yi,'r','linewidth',2);

			newcell=emptycellrec;
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
		analyzetpstack('UpdatePreviewImage',[],fig);
		analyzetpstack('UpdateCellImage',[],fig);
	case {'AnalyzeParamBt','AnalyzeStimBt','AnalyzeDragoiStimBt','AnalyzeRawBt'},
		ud.ds = dirstruct(getpathname(ud.ds));
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
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
		[listofcells,listofcellnames]=getcurrentcellschanges(ud,refdirname,dirname,ancestors);
		fname = stackname; scratchname = fixpath(getscratchdirectory(ud.ds,1));
		needtorun = 1;
		channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
		rawfilename = [scratchname fname '_' dirname '_raw'];
		if exist(rawfilename)==2,
			g = load(rawfilename,'-mat');
			needtorun = ~(g.listofcellnames==listofcellnames);
			if ~needtorun, needtorun = ~eqlen(g.listofcells,listofcells); end;
		end;
		if needtorun,
			[data,t] = tpreaddata(fulldirname,[-Inf Inf],listofcells,1,channel);
			save(rawfilename,'data','t','listofcells','listofcellnames','-mat');
		end;
		pixelarg = load(rawfilename,'-mat');
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
			save([scratchname fname '_' dirname],'resps','listofcells','listofcellnames',...
				'dirname','refdirname','paramname','channel','trialslist','timeint','sptimeint','blankID','-mat');
   			resps=tptuningcurve(fulldirname,channel,paramname,pixelarg,1,listofcellnames,trialslist,timeint,sptimeint,blankID,0);
		else,   % this is bad form, including a specific stim type in general code, but it is faster
			resps=tpTCDragoi(fulldirname,channel,paramname,pixelarg,1,listofcellnames,trialslist,timeint,sptimeint,blankID,~isempty(blankID));
			save([scratchname fname '_' dirname],'resps','listofcells','listofcellnames',...
				'dirname','refdirname','paramname','channel','trialslist','timeint','sptimeint','blankID','-mat');
		end;
	case 'stimdirnameEdit',
		scratchname = fixpath(getscratchdirectory(ud.ds,1));
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		fname = stackname;
		if exist([scratchname fname '_' dirname]),
			g = load([scratchname fname '_' dirname],'-mat');
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
	case 'checkDriftBt',
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		trialsstr = get(ft(fig,'trialsEdit'),'string');
		if ~isempty(trialsstr), trialslist = eval(trialsstr); else, trialslist = []; end;
		timeintstr = get(ft(fig,'timeintEdit'),'string');
		if ~isempty(timeintstr), timeint= eval(timeintstr); else, timeint= []; end;
		sptimeintstr = get(ft(fig,'sptimeintEdit'),'string');
		if ~isempty(sptimeintstr), sptimeint= eval(sptimeintstr); else, sptimeint= []; end;
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
		if iscell(currstr_)&~isempty(currstr_), dirname1 = trimws(currstr_{sliceind1});  % currently selected
		else, disp(['No directories in list to examine.']); return; 
		end;
		[sliceind2,okay]=listdlg('ListString',currstr_,'PromptString','Select dir to compare','SelectionMode','single');
		if isempty(sliceind2), return;
		else, dirname2 = trimws(currstr_{sliceind2});
		end;
		channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
		ancestors2 = getallparents(ud,dirname2);
		ancestors1 = getallparents(ud,dirname1);
		if isempty(intersect(dirname1,ancestors2)), error(['Error checking alignment: ' dirname1 ' and ' dirname2 ' are not recordings at the same place.']); end;
		refdirname = getrefdirname(ud,dirname1); % should be same for both
		[listofcells1,listofcellnames1,mycellstructs,changes1]=getcurrentcellschanges(ud,refdirname,dirname1,ancestors1);
		[listofcells2,listofcellnames2,mycellstructs,changes2]=getcurrentcellschanges(ud,refdirname,dirname2,ancestors2);
		[thelist,thelistinds1,thelistinds2] = intersect(listofcellnames1,listofcellnames2);
		if channel~=1, pvimg1 = eval(['ud.previewimage' num2str(channel) '{sliceind1};']);
		else, pvimg1 = ud.previewimage{sliceind1};
		end;
		if channel~=1, pvimg2 = eval(['ud.previewimage' num2str(channel) '{sliceind2};']);
		else, pvimg2 = ud.previewimage{sliceind2};
		end;
		try, drift1 = getcurrentdirdrift(ud,dirname1,NUMPREVIEWFRAMES); catch, drift1 = [0 0]; end;
		try, drift2 = getcurrentdirdrift(ud,dirname1,NUMPREVIEWFRAMES); catch, drift1 = [0 0]; end;
		plottpcellalignment(listofcellnames1(thelistinds1),listofcellnames2(thelistinds2),changes1(thelistinds1),changes2(thelistinds2),...
			pvimg1,pvimg2,dirname1,dirname2,drift1,drift2,3);
	case 'movieBt',
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
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
		refdirname = getrefdirname(ud,dirname);
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		fname = stackname;
		scratchname = fixpath(getscratchdirectory(ud.ds,1));
		try,
			g=load([scratchname fname '_' dirname],'resps','listofcells','listofcellnames',...
			'dirname','refdirname','-mat');
		catch, 
			errordlg(['Can''t open analysis file.  Please analyze data first.']);
			error(['Can''t open analysis file.  Please analyze data first.']);
		end;
		try, thresh = str2num(get(ft(fig,'mapthreshEdit'),'string'));
		catch, errordlg(['Syntax error in map threshold: ' get(ft(fig,'mapthreshEdit'),'string') '.']);
			error(['Syntax error in map threshold: ' get(ft(fig,'mapthreshEdit'),'string') '.']);
		end;
		im=tpquickmap(fulldirname,channel,g.resps,g.listofcells,1,'threshold',thresh);
	case 'QuickPSTHBt',
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		ancestors = getallparents(ud,dirname);
		[listofcells,listofcellnames]=getcurrentcellschanges(ud,refdirname,dirname,ancestors);
		fname = stackname; scratchname = fixpath(getscratchdirectory(ud.ds,1));
		needtorun = 1;
		channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
		rawfilename = [scratchname fname '_' dirname '_raw'];
		if exist(rawfilename)==2,
			g = load(rawfilename,'-mat');
			needtorun = ~(g.listofcellnames==listofcellnames);
		end;
		if needtorun,
			[data,t] = tpreaddata(fulldirname,[-Inf Inf],listofcells,1,channel);
			save(rawfilename,'data','t','listofcells','listofcellnames','-mat');
			pixelarg = listofcells;
		else,
			pixelarg = load(rawfilename,'-mat');
		end;
		binsize = eval(get(ft(fig,'QuickPSTHEdit'),'string'));
		plotit = 1 + get(ft(fig,'QuickPSTHCB'),'value');
		fprintf('Analyzing...will take a few seconds...\n');
		global mydata myt myavg mybins;
		[mydata,myt,myavg,mybins]=tpquickpsthsliding(fulldirname,channel,[],pixelarg,plotit,listofcellnames,binsize,0.1,0,[]);
	case 'baselineBt',
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname);
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		ancestors = getallparents(ud,dirname);
		[listofcells,listofcellnames]=getcurrentcellschanges(ud,refdirname,dirname,ancestors);
		%tpfile = load([fulldirname filesep 'twophotontimes.txt'],'-ascii'),
		fprintf('Analyzing...will take a few seconds...\n');
		channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
		%[d,t]=tpreaddata(fulldirname,[tpfile(2)+5 tpfile(end)-5],listofcells,1,channel);
		[d,t]=tpreaddata(fulldirname,[0 Inf],listofcells,1,channel);
		figure;
		colors=[ 1 0 0;0 1 0;0 0 1;1 1 0;0 1 1;1 1 1;0.5 0 0;0 0.5 0;0 0 0.5;0.5 0.5 0;0.5 0.5 0.5];
		for i=1:length(ud.celllist),
			hold on;
			ind=mod(i,length(colors)); if ind==0,ind=length(colors); end;
			plot(t{i},d{i},'color',colors(ind,:));
		end;
		legend(listofcellnames);
		ylabel('Raw signal'); xlabel('Time (s)');
	case 'correctDriftBt',
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		refdirname = getrefdirname(ud,dirname),
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		fullrefdirname = [fixpath(getpathname(ud.ds)) refdirname];
		channel=fix(str2num(get(ft(fig,'stimChannelEdit'),'string')));
        prompt = {'Search space in x:','Search space in y:','Search space to match initial reference in x:','Search space to match initial reference in y:',...
            'Correct each N frames:','Average N frames together','Normalize images first?','Use brightest parts only?','Only correct within this directory (I''ll manually align across directories)'};
        name = 'Parameters for drift correction...';
        numlines = 1;
        defaultanswer = {'[-6:2:6]','[-6:2:6]','[-100:10:100]','[-100:10:100]','10','5','1','1','0'};
        answ = inputdlg(prompt,name,numlines,defaultanswer);
        if isempty(answ), return; end;
        searchx = eval(answ{1}); searchy = eval(answ{2}); refsearchx = eval(answ{3}); refsearchy = eval(answ{4}); howoften = eval(answ{5}); howmany = eval(answ{6});
        brightnesscorrect = eval(answ{7}); roicorrect = eval(answ{8});
        onlylocal = eval(answ{9});
        if onlylocal, myfullrefdirname = fulldirname; else, myfullrefdirname = fullrefdirname; end;
		dr=tpdriftcheck(fulldirname,channel,searchx,searchy,myfullrefdirname,refsearchx,refsearchy,howoften,howmany,brightnesscorrect,roicorrect,1,1);
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
                analyzetpstack('UpdateSliceDisplay',[],fig);
            end;
        end;
    case 'shiftDriftBt',
        warndlg('Warning: you should use CheckDrift on a bright cell to check the results of your manual shifts over the duration of the recording.  Even if the shift is good at the beginning of the trial, it may slip later on.  It is recommended that you first try adjusting the drift correct parameters and correcting drift again before resorting to manually shifting.','Warning');
		dirname = get(ft(fig,'stimdirnameEdit'),'string');
		fulldirname = [fixpath(getpathname(ud.ds)) dirname];
		refdirname = getrefdirname(ud,dirname),
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
                analyzetpstack('UpdateSliceDisplay',[],fig);
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
		refdirname = getrefdirname(ud,dirname);
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
		xyoffset = getxyoffset(ud,dirname);
		if foundIt>0,
			addtotpdatabase(ud.ds,refs(foundIt),cellstructs,listofcellnames,'analyzetpstack name',stackname,'depth',depth,'xyoffset',xyoffset);
		else,
			errordlg(['Could not find two-photon reference for directory ' dirname '.']);
		end;
	case 'saveBt',
		fname = stackname;
		scratchname = fixpath(getscratchdirectory(ud.ds,1));
		celllist = ud.celllist;
        slicelist = ud.slicelist;
        previewimage = ud.previewimage;
        previewparams = ud.previewparams;
		changes = {};
		if isfield(ud.celldrawinfo,'changes'), changes = ud.celldrawinfo.changes; end;
		tpassociatelistglobals;
		assoclist=tpassociatelist;
		if exist([scratchname fname '.stack']),
			answer = questdlg('File exists...overwrite?',...
				'File exists...overwrite?','OK','Cancel','Cancel');
			if strcmp(answer,'OK'),
				save([scratchname fname '.stack'],'celllist','slicelist',...
						'previewimage','changes','assoclist','previewparams','-mat');
			end;
		else,
			save([scratchname fname '.stack'],'celllist','slicelist','previewimage','changes','assoclist','previewparams','-mat');
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
            ud.previewimage=g.previewimage;
            if isfield(g,'previewparams'),
                ud.previewparams = g.previewparams;
            else,
                for i=1:length(ud.slicelist),
                    numFrames = NUMPREVIEWFRAMES;
                    [pvimg,params]=tppreview(fullfile(fixpath(getpathname(ud.ds)),ud.slicelist(i).dirname),...
                            numFrames,1,1);
                    sc = getscratchdirectory(ud.ds,1);
                    pvfilename = [sc filesep 'preview_' ud.slicelist(i).dirname '_ch1.mat'];
                    save(pvfilename,'pvimg','params');
                    ud.previewparams{i} = params;
                end;
            end;
			if isfield(g,'changes'), ud.celldrawinfo.changes = g.changes; end;
			if ~isfield(g,'previewchannel'), ud.previewchannel = 1; ud.previewimage2 = {}; ud.previewimage3 = {}; ud.previewimage4 = {};
                ud.previewparams2 = {}; ud.previewparams3 = {}; ud.previewparams4 = {};
            end;
			set(fig,'userdata',ud);
			analyzetpstack('UpdateSliceDisplay',[],fig);	
		else, errordlg(['File ' scratchname fname '.stack does not exist.']);
		end;
		analyzetpstack('UpdateCellList',[],fig);
		analyzetpstack('UpdateSliceDisplay',[],fig);
	case 'ColorMaxEdit',
		ud.previewdir = '';
		set(fig,'userdata',ud);
		analyzetpstack('UpdatePreviewImage',[],fig);
	case 'ColorMinEdit',
		analyzetpstack('ColorMaxEdit',[],fig);
	otherwise,
		disp(['Unhandled command: ' command '.']);
end;

 % speciality functions

function sr = emptyslicerec
sr = struct('dirname','','depth',0,'drawcells',1,'analyzecells',1,'xyoffset',[0 0]);

function cr = emptycellrec
cr = struct('dirname','','pixelinds','','xi','','yi','','index',[],'type','','labels','');

function obj = ft(fig, name)
obj = findobj(fig,'Tag',name);

function refdirname = getrefdirname(ud,dirname)
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

function [listofcells,listofcellnames,cellstructs] = getcurrentcells(ud,refdirname)
listofcells = {}; listofcellnames = {};
cellstructs = emptycellrec; cellstructs = cellstructs([]);
for i=1:length(ud.celllist),
	if strcmp(ud.celllist(i).dirname,refdirname),
		listofcells{end+1} = ud.celllist(i).pixelinds;
		listofcellnames{end+1}=['cell ' int2str(ud.celllist(i).index) ' ref ' ud.celllist(i).dirname];
		cellstructs = [cellstructs ud.celllist(i)];
	end;
end;

function [listofcells,listofcellnames,cellstructs,thechanges] = getcurrentcellschanges(ud,refdirname,currdirname,ancestors)
listofcells = {}; listofcellnames = {}; thechanges = {};
cellstructs = emptycellrec; cellstructs = cellstructs([]);
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
	if ~isempty(i),
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

function str = trimws(mystring)
str = mystring;
inds = find(mystring~=' ');
if length(inds)>0,
	str = mystring(inds(1):end);
end;

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

function dr = getcurrentdirdrift(ud,dirname, numpreviewframes)
tpdirs = tpdirnames([getpathname(ud.ds) dirname]);
if isempty(tpdirs),
	warning(['No driftcorrect file for ' dirname '; shift information will change after drift correction.']);
	dr = [0 0];
else,
	if exist([tpdirs{1} filesep 'driftcorrect'])~=2,
		warning(['No driftcorrect file for ' dirname '; shift information will change after drift correction.']);
		dr = [0 0];
	else,
		load([tpdirs{1} filesep 'driftcorrect'],'-mat');
        try,
		dr = mean(drift(1:numpreviewframes,:)); % just get the initial drift
        catch, dr = drift(1,:); 
        end;
	end;

end;
 % now add XY offset to drift
dr = dr + getxyoffset(ud,dirname);

function xyoffset = getxyoffset(ud,dirname)
myparent = getrefdirname(ud,dirname);
xyoffset = [0 0];
for j=1:length(ud.slicelist),
	if strcmp(myparent,trimws(ud.slicelist(j).dirname)),
		xyoffset = ud.slicelist(j).xyoffset;
	end;
end;


function [slicestructupdate] = updatecelldraw(ud,i,slicestruct,currdir,numpreviewframes)
  % make a lookup table for slicelist, drift, and ancestors, if it doesn't
  % already exist
if isempty(slicestruct),
	slicestruct.slicelistlookup.test = [];
	slicestruct.slicedriftlookup.test = [];
	slicestruct.sliceancestorlookup.test = [];
	for j=1:length(ud.slicelist),
		slicestruct.slicelistlookup=setfield(slicestruct.slicelistlookup,trimws(ud.slicelist(j).dirname),j);
		slicestruct.slicedriftlookup=setfield(slicestruct.slicedriftlookup,trimws(ud.slicelist(j).dirname),getcurrentdirdrift(ud,trimws(ud.slicelist(j).dirname),numpreviewframes));
		slicestruct.sliceancestorlookup=setfield(slicestruct.sliceancestorlookup,trimws(ud.slicelist(j).dirname),getallparents(ud,trimws(ud.slicelist(j).dirname)));	
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
	drift = getfield(slicestructupdate.slicedriftlookup,currdir);
	changes = getChanges(ud,i,currdir,ancestors);
	if changes.present, mycolor = [0 0 1];
  else mycolor = [ 1 0.5 0.5];
	end;
else
	drift = getfield(slicestructupdate.slicedriftlookup, ud.celllist(i).dirname);
	changes = getChanges(ud,i,ud.celllist(i).dirname,[]);
	mycolor = [1 0 0];
end;
set(ud.celldrawinfo.h(i),'color',mycolor);
set(ud.celldrawinfo.t(i),'color',mycolor);
xi = changes.xi; xi(end+1) = xi(1);
yi = changes.yi; yi(end+1) = yi(1);
set(ud.celldrawinfo.h(i),'xdata',xi-drift(1),'ydata',yi-drift(2));
set(ud.celldrawinfo.t(i),'position',[mean(xi)-drift(1) mean(yi)-drift(2) 0]);

