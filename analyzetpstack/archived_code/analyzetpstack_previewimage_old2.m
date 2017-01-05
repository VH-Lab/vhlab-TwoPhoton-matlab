function varargout = analyzetpstack_previewimage(command, thestackname, thefig, arg4)

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

 % commands that alter user data:
 %    previewWindowInit
 %    InitializePreviewImageVars'
 %    GetPreviewImage
command,

NUMPREVIEWFRAMES = 30;  % gotta make this a global variable / preference down the road

ud = get(fig,'userdata');


  % variables in ud
  %     previewchannel - means the current menu item number in the channel menu that is selected
  %     previewdir - the current directory that is being displayed in the preview channel
  %     previewim - the current preview image handle
  %     previewimage % preview image data
  %     previewparams % preview image parameters
  %     previewimage2, previewimage3, previewimage4 % preview image data
  %     previewparams2, previewparams3, previewparams4  % preview image parameters
  %
  %         PRESENT:
  %         these are created empty in analyzetpstack: Init
  %         these are modified by analyzetpstack_slicelist:  Add, RemoveSliceBt, Load
  %          
  %    Current: Only variable necessary should be internal variable previewdata
  %             GetPreviewImage  -- get the current preview image by calling GetPreviewImageData
  %             GetPreviewImageData - get preview image data for an arbitrary channel and view
  %             analyzetpstack_previewimage: 'GetCurrentPreviewImageHandle'* 


switch command,
	case 'previewWindowInit',    %% updates userdata of analyzetpstackwindow
		% arg4 is the rectangle
		button.Units = 'pixels';
		button.BackgroundColor = [0.8 0.8 0.8];
		button.HorizontalAlignment = 'center';
		button.Callback = 'analyzetpstack_previewimage(gcbo);';
		txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8];
		txt.fontsize = 12; txt.fontweight = 'normal';
		txt.HorizontalAlignment = 'center';txt.Style='text';
		edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit'; edit.Callback = 'analyzetpstack_previewimage(gcbo);';
		popup = txt; popup.style = 'popupmenu'; popup.Callback = 'analyzetpstack_previewimage(gcbo)';
		cb = txt; cb.Style = 'Checkbox'; cb.Callback = 'analyzetpstack_previewimage(gcbo)';
		cb.fontsize = 12;

		% make the imaging axes
		sh=50+10;
		h=axes('units','pixels','position',[5 5 770 770],'Tag','tpaxes','box','off','YTick',[],'XTick',[]);

		% these are the shifts imported from analyzetpstack.m

		uicontrol(txt,'position',[780 612-5 80 20],'String','Color min','horizontalalignment','center');
		uicontrol(txt,'position',[780 562-5 80 20],'String','Color max','horizontalalignment','center');
                uicontrol(edit,'position',[780 581 70 20],'String','0','horizontalalignment','center','Tag','ColorMinEdit');
                uicontrol(edit,'position',[780 537 70 20],'String','1000','horizontalalignment','center','Tag','ColorMaxEdit');
		uicontrol(popup,'position',[780 512 100 20],'String',...
			{'Ch 1','Ch 2','Ch 3','Ch 4','Ch1+2'}','value',1,...
			'horizontalalignment','center','tag','channelPopup');
		uicontrol(popup,'position',[780 512-25 100 20],'String',...
			{'View1','View2','View3','View4'}','value',1,...
			'horizontalalignment','center','tag','viewPopup','visible','off');
		
		% add variables
		analyzetpstack_previewimage('InitializePreviewImageVars',[],fig);

	case 'InitializePreviewImageVars',  % UPDATES USERDATA OF FIG updates userdata
		ud.previewimage = {};
		ud.previewparams = {};
		ud.previewdir = [];
		ud.previewchannel = 1;
		ud.previewimage2 = {};
		ud.previewparams2 = {};
		ud.previewimage3 = {};
		ud.previewparams3 = {};
		ud.previewimage4 = {};
		ud.previewparams4 = {};
		ud.previewim = [];
		ud.linescanpreview = [];
		set(fig,'userdata',ud);

	case 'UpdatePreviewImage',  %% updates userdata of analyzestpack window
		v = get(ft(fig,'sliceList'),'value');
		dirname = trimws(ud.slicelist(v).dirname);
		xyoffset = analyzetpstack_getxyoffset(ud,dirname);
                channelPopupValue = get(ft(fig,'channelPopup'),'value');
		if ishandle(ud.linescanpreview),
			if ud.slicelist(v).analyzecells,
				set(ud.linescanpreview,'visible', 'on');
			else,
				set(ud.linescanpreview,'visible','off');
			end;
		end;
		if ~strcmp(dirname,ud.previewdir)|channelPopupValue~=ud.previewchannel,  % we need to update
			if ishandle(ud.previewim),
				delete(ud.previewim);
			end;
			if isfield(ud,'linescanpreview'),
				if ishandle(ud.linescanpreview),
					delete(ud.linescanpreview);
				end;
			end;
			[previewimage,previewparams] = analyzetpstack_previewimage('GetPreviewImage',[],fig);
			ud = get(fig,'userdata'); % reload userdata


			if isempty(previewimage), % bad choice, exit gracefully
				set(ft(fig,'channelPopup'),'value',ud.previewchannel);
				ud.previewdir = dirname;
				ud.previewchannel = 0;
				set(fig,'userdata',ud);
				analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
				return;
			end;

			axes(ft(fig,'tpaxes'));

			% now draw it
			ud.previewim = image(previewimage);
			set(ud.previewim,'xdata',get(ud.previewim,'xdata')-xyoffset(1),'ydata',get(ud.previewim,'ydata')-xyoffset(2));
			if isfield(previewparams{1},'Type')
				if strcmp(previewparams{1}.Type,'Linescan'),
					hold on;
					ud.linescanpreview=plot(previewparams{1}.Linescanpoints(:,1)-xyoffset(1),previewparams{1}.Linescanpoints(:,2)-xyoffset(1),'y','linewidth',1);
				end;
			end;

			ud.previewdir = dirname;
			ud.previewchannel = channelPopupValue;
			colormap(gray(256));
			set(gca,'tag','tpaxes'); % make sure the axes retain their name

			% now make sure the preview image is on bottom and that the linescan preview is on top
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
					if ud.slicelist(v).analyzecells,
						set(ch(1),'visible', 'on');
					else,
						set(ch(1),'visible','off');
					end;
					set(gca,'children',ch);
				end;
			end;
			set(fig,'userdata',ud);
			set(gca,'box','off','YTick',[],'XTick',[])
		end;
	case 'FunctionListCompute'
		filepath = getpathname(ud.ds);
		TPPreviewImageFunctionListCompute([filepath filesep thestackname]);
	case 'ColorMaxEdit',
		ud.previewdir = '';
		set(fig,'userdata',ud);
		analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
	case 'ColorMinEdit',
		analyzetpstack_previewimage('ColorMaxEdit',[],fig);
	case 'channelPopup',
		analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
		analyzetpstack('UpdateCellImage',[],fig);
		analyzetpstack('UpdateCellLabels',[],fig);
	case 'viewPopup',
		analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
		analyzetpstack('UpdateCellImage',[],fig);
		analyzetpstack('UpdateCellLabels',[],fig);
	case 'GetSettings',
		try,
			mn=str2num(get(ft(fig,'ColorMinEdit'),'string'));
		catch,
			errordlg(['Syntax error in colormin.']); mn=0;
		end;
		try,
			mx=str2num(get(ft(fig,'ColorMaxEdit'),'string'));
		catch,
			errordlg(['Syntax error in colormax.']); mx=0;
		end;
		channelPopupValue = get(ft(fig,'channelPopup'),'value');
		view = get(ft(fig,'viewPopup'),'value');
		switch channelPopupValue,
			case {1,2,3,4},
				channel = channelPopupValue;
			case {5},
				channel = [1 2];
		end;
		varargout{1} = mn;
		varargout{2} = mx;
		varargout{3} = channel;
		varargout{4} = view;
	case 'GetPreviewImage',
		[mn,mx,channel,view] = analyzetpstack_previewimage('GetSettings',[],fig);
		% this command potentially alters figure userdata, so figure userdata should be re-read after running this command
		v = get(ft(fig,'sliceList'),'value');
                dirname = trimws(ud.slicelist(v).dirname);

		% varargout{1} is previewimage
		% varargout{2} is previewparams
		previewimage = {};
		previewparams = {};
		for i=1:length(channel),
			[previewimage{i},previewparams{i}] = analyzetpstack_previewimage('GetPreviewImageData',[],fig,...
				struct('channel',channel(i),'dirname',dirname));
			previewimage{i} = rescale(double(previewimage{i}),[mn mx],[0 255]);
		end;
		switch length(previewimage),
			case 1,
				previewimage = previewimage{1};
			case 2,
				previewimage = cat(3,previewimage{2}/255,previewimage{1}/255,previewimage{2}/255);
			case 3,
				previewimage = cat(3,previewimage{2}/255,previewimage{1}/255,previewimage{3}/255);
		end;
		varargout{1} = previewimage;
		varargout{2} = previewparams;
	case 'GetPreviewImageHandle',
		varargout{1} = ud.previewim;	
	case 'GetPreviewImageData', % gets a single channel's worth of preview data and possibly updates USERDATA
		channel = arg4.channel;
		dirname = arg4.dirname;
		dirnamelist = strtrim(get(ft(fig,'sliceList'),'string')); % trim off whitespace of these
		v = strmatch(dirname,dirnamelist);
		
		%if channel==1, % assume it exists
		%	previewimage=ud.previewimage{v};
		%	previewparams = ud.previewparams{v};
		%else,
			if channel==1,
				chstr = '';
			else,
				chstr = int2str(channel); 
			end;
			% find out if it is in memory
			%eval(['b=length(ud.previewimage' chstr ')<v;']);
			%eval(['if ~b, b=isempty(ud.previewimage' chstr '{v});end;']);
			%if b,  % if we haven't loaded this preview image yet, then load it or create it
				try,
					sc = getscratchdirectory(ud.ds,1);
					pvfilename = [sc filesep 'preview_' dirname '_ch' chstr '.mat'];
					gotit = 0;
					if exist(pvfilename)==2,
						disp(['loading preview image from disk']);
						load(pvfilename);
						if exist('pvimg')==1 & exist('pvparams')==1, 
							gotit = 1;
						end;
					end;
					if ~gotit,
						disp(['generating new preview image']);
						[pvimg,pvparams]=tppreview([fixpath(getpathname(ud.ds)) filesep dirname],...
							NUMPREVIEWFRAMES,1,channel);
						save(pvfilename,'pvimg','pvparams');
					end;
			%		eval(['ud.previewimage' chstr '{v} = pvimg;']);
			%		eval(['ud.previewparams' chstr '{v} = pvparams;']);
			%		set(fig,'userdata',ud);
				catch,
					disp(['No data on channel ' int2str(channel) '.']);
				end;
			%end;
			%eval(['b=length(ud.previewimage' chstr ')<v;']);
			%eval(['if ~b, b=isempty(ud.previewimage' chstr '{v});end;']);
			%if ~b,
			%	eval(['previewimage=ud.previewimage' chstr '{v};']);
			%	eval(['previewparams=ud.previewparams' chstr '{v};']);
		 	%else, % no data
			%end;
		%end;
		varargout{1} = pvimg;
		varargout{2} = pvparams;
end;

function obj = ft(fig, name)
obj = findobj(fig,'Tag',name);

