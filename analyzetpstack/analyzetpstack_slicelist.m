function analyzetpstack_slicelist(command, thestackname, thefig, arg4)

if nargin==0, % it is a callback
	h1 = gcbf;
	analyzetpstack_slicelist(gcbo);
	return;
end;

if nargin>=3,  % then is command w/ fig as 3rd arg
    fig = thefig;
    ud = get(fig,'userdata');
    stackname = get(findobj(fig,'Tag','stacknameEdit'),'string');
end;

if ~isa(command,'char'),
    % if not a string, then command is a callback object
    command = get(command,'Tag');
    fig = gcbf;
    stackname = get(findobj(fig,'tag','stacknameEdit'),'string');
end;

command,

NUMPREVIEWFRAMES = 30;  % gotta make this a global variable / preference down the road

ud = get(fig,'userdata');

switch command,
	case 'sliceListInit',
		% arg4 is the rectangle

		button.Units = 'pixels';
		button.BackgroundColor = [0.8 0.8 0.8];
		button.HorizontalAlignment = 'center';
		button.Callback = 'analyzetpstack_slicelist;';
		txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8];
		txt.fontsize = 12; txt.fontweight = 'normal';
		txt.HorizontalAlignment = 'center';txt.Style='text';
		edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';
		popup = txt; popup.style = 'popupmenu'; popup.Callback = 'analyzetpstack_slicelist';
		cb = txt; cb.Style = 'Checkbox'; cb.Callback = 'analyzetpstack_slicelist';
		cb.fontsize = 12;

		figure(fig);
		uicontrol(popup,'position',arg4, 'String',...
			{'Slice command:','------',...
				'Add new slice','Remove selected slice','------',...
				'Add to database', 'Check slice alignment','------',...
				'Macros:', ...
				'Analyze all raw and add to database'
				},...
			'Tag','sliceListPopup');
	case 'sliceListPopup',
		newcommand = '';
		v = get(findobj(fig,'Tag','sliceListPopup'),'value');
		str = get(findobj(fig,'Tag','sliceListPopup'),'string');
		if ~isempty(v),
			switch str{v},
				case 'Add new slice',
					newcommand = 'AddSliceBt';
				case 'Remove selected slice',
					newcommand = 'RemoveSliceBt',
				case 'Add to database',
					newcommand = 'AddDBBt';
				case 'Check slice alignment',
					newcommand = 'checkAlignmentBt';
				case 'Analyze all raw and add to database',
					newcommand = 'AnalyzeAllRawAddToDatabaseBt',
			end;
		end;
		set(findobj(fig,'Tag','sliceListPopup'),'value',1);
		if ~isempty(newcommand),
			analyzetpstack_slicelist(newcommand,[],fig);
		end;
	case 'sliceList', % user clicks in the slice list
		analyzetpstack_slicelist('UpdateSliceDisplay',[],fig);
	case 'AddSliceBt', % writes userdata
		ud.ds = dirstruct(getpathname(ud.ds));
		set(fig,'userdata',ud);
		dirlist = getalltests(ud.ds);
		if isempty(dirlist), errordlg(['No directories in ' getpathname(ud.ds) ' to add....']); return; end;
		[s,ok] = listdlg('ListString',dirlist);
		if ok==1,
			analyzetpstack_slicelist('Add',[],fig,dirlist(s));
		end;
		analyzetpstack_slicelist('UpdateSliceDisplay',[],fig);
	case 'Add',
		dirlist = arg4;
		for s=1:length(dirlist),
			disp(['Now adding slice directory ' dirlist{s} '.']);
			newslice = analyzetpstack_emptyslicerec;
			newslice.dirname = dirlist{s};
			%in the future , the preview image stuff should be moved elsewhere
			if 0,
			numFrames = NUMPREVIEWFRAMES;
			channel = 1;
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
			end;
			ud.slicelist = [ud.slicelist newslice];
		end;
		set(fig,'userdata',ud);
		%analyzetpstack_previewimage('FunctionListCompute',dirlist{s},fig);
		analyzetpstack_slicelist('UpdateSliceDisplay',[],fig);
	case 'RemoveSliceBt',
		v = get(findobj(fig,'Tag','sliceList'),'value');
		dirname = get(findobj(fig,'Tag','sliceList'),'string');
		if isempty(v)|~iscell(dirname), errordlg(['No selected slice to remove']); return; end;
		dirname = trimws(dirname{v}),
		ud.slicelist = [ud.slicelist(1:(v-1)) ud.slicelist((v+1):end)];
		% this is depricated, there is no use of ud.previewimage anymore, now in analyzetpstack_previewimage and
		%  more sophisticated treatment
		%ud.previewimage = [ud.previewimage(1:(v-1));ud.previewimage((v+1):end)];
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
		analyzetpstack_slicelist('UpdateSliceDisplay',[],fig);
		analyzetpstack('UpdateCellList',[],fig);

	case 'AnalyzeAllRawAddToDatabaseBt',
		sl = get(findobj(fig,'Tag','sliceList'),'string');
		for v=1:length(sl),
			set(findobj(fig,'Tag','sliceList'),'value',v);
			analyzetpstack_slicelist('UpdateSliceDisplay',[],fig);
			f = gcf;
			analyzetpstack('AnalyzeRawBt',[],fig);
			fnew = gcf;
			if fnew~=f & 0, % turn this off, it is probably useful to force user to look at results
				close(fnew);
			end
		end
		for v=1:length(sl),
			set(findobj(fig,'Tag','sliceList'),'value',v);
			analyzetpstack_slicelist('AddDBBt',[],fig);
		end

	case 'checkAlignmentBt',
		sliceind1 = get(findobj(fig,'Tag','sliceList'),'value');
		currstr_ = get(findobj(fig,'Tag','sliceList'),'string');
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
		channel=fix(str2num(get(findobj(fig,'Tag','stimChannelEdit'),'string')));
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
		plottpcellalignment(listofcellnames1(thelistinds1),listofcellnames2(thelistinds2),...
			changes1(thelistinds1),changes2(thelistinds2),...
			pvimg1,pvimg2,dirname1,dirname2,drift1,drift2,3);
	case 'AddDBBt',
		ud.ds = dirstruct(getpathname(ud.ds));
		sv = get(findobj(fig,'tag','sliceList'),'value');
		dirname = trimws(ud.slicelist(sv).dirname);
		[listofcells,listofcellnames,cellstructs]=analyzetpstack_getcurrentcells(ud,dirname);
		refs = getnamerefs(ud.ds,dirname);
		foundIt=0;
		for i=1:length(refs), if strcmp(refs(i).name,'tp'), foundIt = i; break; end; end;
		depth=num2str(get(findobj(fig,'tag','depthEdit'),'string'));
		xyoffset = analyzetpstack_getxyoffset(ud,dirname);
		if foundIt>0,
			analyzetpstack_addtotpdatabase(ud.ds,refs(foundIt),cellstructs,listofcellnames,'analyzetpstack name',stackname,'depth',depth,'xyoffset',xyoffset);
		else,
			errordlg(['Could not find two-photon reference for directory ' dirname '.']);
		end;
	case 'UpdateSliceDisplay',
		v_ = get(findobj(fig,'Tag','sliceList'),'value');
		currstr_ = get(findobj(fig,'Tag','sliceList'),'string');
		if iscell(currstr_)&~isempty(currstr_), selDir = trimws(currstr_{v_});  % currently selected
		else, selDir = {};
		end;
		set(findobj(fig,'Tag','stimdirnameEdit'),'string',selDir);
		inds = [];
		newlist = {};
		currInds = 1:length(ud.slicelist);
		while ~isempty(currInds),
			parentdir = analyzetpstack_getrefdirname(ud,ud.slicelist(currInds(1)).dirname);
			if strcmp(parentdir,ud.slicelist(currInds(1)).dirname),  % if it is a parent directory, find all its kids
				newlist{end+1} = parentdir;
				inds(end+1) = currInds(1);
				currInds = setdiff(currInds,currInds(1));  % we will include this as a parent
				kids = [];
				for j=currInds,
					myparent = analyzetpstack_getrefdirname(ud,ud.slicelist(j).dirname);
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
		set(fig,'userdata',ud);
		set(findobj(fig,'Tag','sliceList'),'string',newlist,'value',v);
		if length(ud.slicelist)~=0,
			set(findobj(fig,'Tag','DrawLinescansCB'),'value',ud.slicelist(v).analyzecells);
			set(findobj(fig,'Tag','DrawCellsCB'),'value',ud.slicelist(v).drawcells);
			set(findobj(fig,'Tag','depthEdit'),'string',num2str(ud.slicelist(v).depth));
			set(findobj(fig,'Tag','sliceOffsetEdit'),'string',['[' num2str(ud.slicelist(v).xyoffset) ']']);
			parentdir = analyzetpstack_getrefdirname(ud,trimws(ud.slicelist(v).dirname));
			if ~strcmp(parentdir,trimws(ud.slicelist(v).dirname)),
				set(findobj(fig,'Tag','sliceOffsetEdit'),'visible','off');
				set(findobj(fig,'Tag','sliceOffsetText'),'visible','off');
			else,
				set(findobj(fig,'Tag','sliceOffsetEdit'),'visible','on');
				set(findobj(fig,'Tag','sliceOffsetText'),'visible','on');
			end;
		end;
		analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
		analyzetpstack('UpdateCellImage',[],fig);
		analyzetpstack('UpdateCellLabels',[],fig);
end;
