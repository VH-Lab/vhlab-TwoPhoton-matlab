function varargout = analyzetpstack_previewimage(command, thestackname, thefig, arg4)

debugging = 0;

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
 %    UpdatePreviewImage
if debugging,
	command,
end;

NUMPREVIEWFRAMES = 30;  % gotta make this a global variable / preference down the road

ud = get(fig,'userdata');


  % variables in ud
  %     previewdir - the current directory that is being displayed in the preview channel
  %     previewim - the current preview image handle
  %     previewimage % preview image data
  %     previewparams % preview image parameters
  %
  %         PRESENT:
  %         these are created empty in analyzetpstack: Init
  %         these are modified by analyzetpstack_slicelist:  Add, RemoveSliceBt, Load


switch command,
	case 'previewWindowInit',    %% updates userdata of analyzetpstackwindow
		% arg4 is the rectangle
		button.Units = 'pixels';
		button.BackgroundColor = [0.7 0.7 0.7]*0.94/0.7;
		button.HorizontalAlignment = 'center';
		button.Callback = 'analyzetpstack_previewimage(gcbo);';
		slider = button; slider.style = 'slider';
		txt.Units = 'pixels'; txt.BackgroundColor = [0.7 0.7 0.7]*0.94/0.7;
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

		sh = 150;

		uicontrol(txt,'position',[780 612-5+sh 80 20],'String','Color min','horizontalalignment','left');
		uicontrol(txt,'position',[780 562-5+sh 80 20],'String','Color max','horizontalalignment','left');
                uicontrol(edit,'position',[780 581+sh 200 24],'String','0','horizontalalignment','center','Tag','ColorMinEdit');
                uicontrol(edit,'position',[780 537+sh 200 24],'String','2000','horizontalalignment','center','Tag','ColorMaxEdit');
		uicontrol(popup,'position',[780 512+sh 100 20],'String',...
			{'Ch 1','Ch 2','Ch 3','Ch 4','Ch1+2'}','value',1,...
			'horizontalalignment','center','tag','channelPopup');
		uicontrol(popup,'position',[780 512-25+sh 100 20],'String',...
			{'default'}','value',1,...
			'horizontalalignment','center','tag','viewPopup','visible','on');
		uicontrol(button,'position',[780 512-50+sh 20 20],'String','<<','tag','RewindBt','horizontalalignment','center');
		uicontrol(button,'position',[780+22 512-50+sh 20 20],'String','<','tag','ReverseBt','horizontalalignment','center',...
				'userdata',0);
		uicontrol(button,'position',[780+22+22 512-50+sh 20 20],'String','>','tag','PlayBt','horizontalalignment','center',...
				'userdata',0);
		uicontrol(button,'position',[780+3*22 512-50+sh 20 20],'String','>>','tag','FastforwardBt','horizontalalignment','center');
		uicontrol(txt,'position',   [780 512-75+sh 45 20],'string','Frame:','tag','FrameLabelTxt','horizontalalignment','left');
		uicontrol(txt,'position',   [780+50 512-75+sh 50 20],'string','Preview','tag','FrameSliderTxt','horizontalalignment','right');
		uicontrol(slider,'position',[780 512-100+sh 100 20],'min',0,'max',10,'value',0,'tag','FrameSlider','SliderStep',[1 1]/11);
		
		analyzetpstack_previewimage('UpdateViewPopup',[],fig);
		% add variables
		analyzetpstack_previewimage('InitializePreviewImageVars',[],fig);

	case 'InitializePreviewImageVars',  % UPDATES USERDATA OF FIG updates userdata
		ud.previewimage = {};
		ud.previewparams = {};
		ud.previewdir = [];
		ud.previewchannel = 1;
		ud.previewim = [];
		ud.linescanpreview = [];
		ud.previewimagecurrentview = [];
		ud.previewimagecurrentframe = 0;
		set(fig,'userdata',ud);

	case 'UpdatePreviewImage',  %% updates userdata of analyzestpack window
		v = get(ft(fig,'sliceList'),'value');
		dirname = trimws(ud.slicelist(v).dirname);
		channelPopupValue = get(ft(fig,'channelPopup'),'value');
		viewString = get(ft(fig,'viewPopup'),'string');
		viewValue = get(ft(fig,'viewPopup'),'value');
		selectedView = viewString{viewValue};
		selectedFrame = get(ft(fig,'FrameSlider'),'value');

		if ishandle(ud.linescanpreview),
			if ud.slicelist(v).analyzecells,
				set(ud.linescanpreview,'visible', 'on');
			else,
				set(ud.linescanpreview,'visible','off');
			end;
		end;

		% check if we need to update
		dir_updated = ~strcmp(dirname,ud.previewdir);
		view_updated = ~strcmp(selectedView,ud.previewimagecurrentview);
		channel_updated = (channelPopupValue~=ud.previewchannel);
		frame_updated = (selectedFrame~=ud.previewimagecurrentframe);
	
		if dir_updated | view_updated | channel_updated | frame_updated, % we need to redraw

			if dir_updated, % we need to reset frame data
				set(ft(fig,'FrameSlider'),'value',0);
				analyzetpstack_previewimage('UpdateFrameCounter',[],fig);
				selectedFrame = 0;
			end;

			if ishandle(ud.previewim),
				delete(ud.previewim);
			end;
			if isfield(ud,'linescanpreview'),
				if ishandle(ud.linescanpreview),
					delete(ud.linescanpreview);
				end;
			end;
			[previewimage,previewparams,shiftx,shifty,total_frames] = analyzetpstack_previewimage('GetPreviewImage',[],fig);
			if iscell(previewparams{1}),
				previewparams{1} = previewparams{1}{1};
			end;
			if dir_updated,
                if isempty(total_frames), warning(['total_frames is empty.']); end;
				set(ft(fig,'FrameSlider'),'min',0,'max',total_frames,'value',0,'SliderStep',[1 1]/total_frames);
			end;

			if isempty(previewimage), % bad choice, exit gracefully
				set(ft(fig,'channelPopup'),'value',ud.previewchannel);
				ud.previewdir = dirname;
				pickone = randperm(4);
				ud.previewchannel = pickone(1);
				set(fig,'userdata',ud);
				analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
				return;
			end;

			axes(ft(fig,'tpaxes'));

			% now draw it
			ud.previewim = image(previewimage);
			set(ud.previewim,'xdata',get(ud.previewim,'xdata')+shiftx,'ydata',get(ud.previewim,'ydata')+shifty);
			if isfield(previewparams{1},'Type')
				if strcmp(previewparams{1}.Type,'Linescan'),
					hold on;
					ud.linescanpreview=plot(previewparams{1}.Linescanpoints(:,1)-xyoffset(1), ...
						previewparams{1}.Linescanpoints(:,2)-xyoffset(1),'y','linewidth',1);
				end;
			end;

			ud.previewdir = dirname;
			ud.previewchannel = channelPopupValue;
			ud.previewimagecurrentview = selectedView;
			ud.previewimagecurrentframe = selectedFrame;

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
	case 'UpdateFrameCounter',
		f = get(ft(fig,'FrameSlider'),'value');
		if f==0,
			set(ft(fig,'FrameSliderTxt'),'string','Preview');
		else,
			set(ft(fig,'FrameSliderTxt'),'string',int2str(f));
		end;
	case 'channelPopup',
		analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
		analyzetpstack('UpdateCellImage',[],fig);
		analyzetpstack('UpdateCellLabels',[],fig);
	case 'viewPopup',
		analyzetpstack_previewimage('UpdateViewPopup',[],fig);
		analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
		analyzetpstack('UpdateCellImage',[],fig);
		analyzetpstack('UpdateCellLabels',[],fig);
	case 'UpdateViewPopup',
		viewValue = get(ft(fig,'viewPopup'),'value');
		viewStrings = get(ft(fig,'viewPopup'),'string');
		if length(viewStrings)>0,
			thecurrentstring = viewStrings(viewValue);
		else,
			thecurrentstring = '';
		end;
		thelist = TPPreviewImageFunctionListGet;
		match = 0;
		newstr = {};
		for i=1:length(thelist),
			newstr{end+1} = thelist(i).shortname;
			if strcmp(thecurrentstring,thelist(i).shortname),
				match = i;
			end;
		end;
		set(ft(fig,'viewPopup'),'string',newstr);
		if match~=0,
			set(ft(fig,'viewPopup'),'value',match);
		else,
			set(ft(fig,'viewPopup'),'value',1);
		end;
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
		if length(mn)==1,
			mn = [mn mn mn mn];
			set(ft(fig,'ColorMinEdit'),'String',mat2str(mn));
		end;
		if length(mx)==1,
			mx = [mx mx mx mx];
			set(ft(fig,'ColorMaxEdit'),'String',mat2str(mx));
		end;

		channelPopupValue = get(ft(fig,'channelPopup'),'value');
		view = get(ft(fig,'viewPopup'),'value');
		viewnames = get(ft(fig,'viewPopup'),'string');
		switch channelPopupValue,
			case {1,2,3,4}, channel = channelPopupValue;
			case 5, channel = [1 2];
			case 6, channel = [1 3];
			case 7, channel = [2 3];
			case 8, channel = [1 4];
			case 9, channel = [2 4];
			case 10, channel = [3 4];
			case 11, channel = [1 2 3];
			case 12, channel = [1 2 4];
			case 13, channel = [1 3 4];
			case 14, channel = [2 3 4];
			otherwise, error(['Odd channelPopupValue ' int2str(channelPopupValue) '.']);
		end;

		currentFrame = round(get(ft(fig,'FrameSlider'),'value'));
		set(ft(fig,'FrameSlider'),'value',currentFrame); 

		varargout{1} = mn;
		varargout{2} = mx;
		varargout{3} = channel;
		varargout{4} = viewnames{view};
		varargout{5} = currentFrame;
	case 'GetPreviewImage',
		[mn,mx,channel,view,frame] = analyzetpstack_previewimage('GetSettings',[],fig);
		v = get(ft(fig,'sliceList'),'value');
                dirname = trimws(ud.slicelist(v).dirname);

		xyoffset = analyzetpstack_getxyoffset(ud,dirname);
		% varargout{1} is previewimage
		% varargout{2} is previewparams
		% varargout{3} is shiftx: -xyoffset(x) + ((drift(current_Frame) - drift(initialframe)))
		% varargout{4} is shifty: -xyoffset(y) + ((drift(current_Frame) - drift(initialframe)))
                % varargout{5} is number of frames available here
		previewimage = {};
		previewparams = {};
		for i=1:length(channel),
			[previewimage{i},previewparams{i},total_frames] = analyzetpstack_previewimage('GetPreviewImageData',[],fig,...
				struct('channel',channel(i),'dirname',dirname,'view',view,'frame',frame));
			if size(previewimage{i},3)==1, % if a single color image
				previewimage{i} = rescale(double(previewimage{i}),[mn(channel(i)) mx(channel(i))],[0 255]);
			else,
				for j=1:size(previewimage{i},3),
					previewimage{i}(:,:,j) = rescale(double(previewimage{i}(:,:,j)),[mn(j) mx(j)],[0 1]);
				end;
			end;
		end;
		switch length(previewimage),
			case 1,
				previewimage = previewimage{1};
			case 2,
				previewimage = cat(3,previewimage{2}/255,previewimage{1}/255,previewimage{2}/255);
				TwoPhotonGlobals;
				if ~isempty(TwoPhotonColorPermute),
					previewimage = previewimage(:,:,[TwoPhotonColorPermute]);
				end;
			case 3,
				previewimage = cat(3,previewimage{2}/255,previewimage{1}/255,previewimage{3}/255);
				TwoPhotonGlobals;
				if ~isempty(TwoPhotonColorPermute),
					previewimage = previewimage(:,:,[TwoPhotonColorPermute]);
				end;
		end;
		[initial_drift,drift] =analyzetpstack_getdirdrift(ud,dirname);
		xyoffset = analyzetpstack_getxyoffset(ud,dirname);
		varargout{1} = previewimage;
		varargout{2} = previewparams;
		varargout{3} = -xyoffset(1)+(drift(max(frame,1),1)-initial_drift(1));
		varargout{4} = -xyoffset(2)+(drift(max(frame,1),2)-initial_drift(2));
		varargout{5} = total_frames;
	case 'GetPreviewImageHandle',
		varargout{1} = ud.previewim;	
	case 'GetPreviewImageData', % gets a single channel's worth of preview data and possibly updates USERDATA
		channel = arg4.channel;
		dirname = arg4.dirname;
		dirnamelist = strtrim(get(ft(fig,'sliceList'),'string')); % trim off whitespace of these
		view = arg4.view;
		frame = arg4.frame;
		v = strmatch(dirname,dirnamelist);
		experpath = getpathname(ud.ds);

		try,
			[varargout{1}, varargout{2},varargout{3}] = TPPreviewImageFunctionListGetPreviewImageParams(...
				fullfile(experpath,dirname),view,channel,frame);
		catch,
			varargout{1} = [];
			varargout{2} = [];
			varargout{3} = [];
			errorstack = lasterror;
			errordlg(['Error loading image data on channel ' int2str(channel) '; usually data does not exist although there may be a problem with the preview compute function.  Error message was ' errorstack.message ' : ' errorstack.identifier]);
		end;
	case 'PlayBt',
		%disp(['Play button']);
		
		out = int8(get(ft(fig,'PlayBt'),'userdata'));
		if out==0,
			set(ft(fig,'PlayBt'),'userdata',1,'BackgroundColor',0.7*[1 1 1]);
			set(ft(fig,'ReverseBt'),'userdata',0,'BackgroundColor',0.94*[1 1 1]);
			keepPlaying = 1;
		else,
			set(ft(fig,'PlayBt'),'userdata',0,'BackgroundColor',0.94*[1 1 1]);
			set(ft(fig,'ReverseBt'),'userdata',0,'BackgroundColor',0.94*[1 1 1]);
			keepPlaying = 0;
		end;

		while keepPlaying,
			out = get(ft(fig,'PlayBt'),'userdata');
			if out~=1,
				keepPlaying = 0;
			end;
			mx = get(ft(fig,'FrameSlider'),'max');
			v = get(ft(fig,'FrameSlider'),'value');
			v = min(v+1, mx);
			set(ft(fig,'FrameSlider'),'value',v);
			analyzetpstack_previewimage('UpdateFrameCounter',[],fig);
			analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
			drawnow;
			if v==mx,
				analyzetpstack_previewimage('PlayBt',[],fig);
			end;
		end;
	case 'ReverseBt',
		%disp(['Reverse button']);
		out = int8(get(ft(fig,'ReverseBt'),'userdata'));
		if out==0,
			set(ft(fig,'ReverseBt'),'userdata',1,'BackgroundColor',0.7*[1 1 1]);
			set(ft(fig,'PlayBt'),'userdata',0,'BackgroundColor',0.94*[1 1 1]);
			keepPlaying = 1;
		else,
			set(ft(fig,'PlayBt'),'userdata',0,'BackgroundColor',0.94*[1 1 1]);
			set(ft(fig,'ReverseBt'),'userdata',0,'BackgroundColor',0.94*[1 1 1]);
			keepPlaying = 0;
		end;

		while keepPlaying,
			out = get(ft(fig,'ReverseBt'),'userdata');
			if out~=1,
				keepPlaying = 0;
			end;
			v = get(ft(fig,'FrameSlider'),'value');
			v = max(v-1, 1);
			set(ft(fig,'FrameSlider'),'value',v);
			analyzetpstack_previewimage('UpdateFrameCounter',[],fig);
			analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
			drawnow;
			if v==1,
				analyzetpstack_previewimage('ReverseBt',[],fig);
			end;
		end;
	case 'RewindBt',
		set(ft(fig,'FrameSlider'),'value',1);
		analyzetpstack_previewimage('UpdateFrameCounter',[],fig);
		analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
	case 'FastforwardBt',
		mx = get(ft(fig,'FrameSlider'),'max');
		set(ft(fig,'FrameSlider'),'value',mx);
		analyzetpstack_previewimage('UpdateFrameCounter',[],fig);
		analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
	case 'FrameSlider',
		analyzetpstack_previewimage('UpdateFrameCounter',[],fig);
		analyzetpstack_previewimage('UpdatePreviewImage',[],fig);
end;

function obj = ft(fig, name)
obj = findobj(fig,'Tag',name);

