function varargout = driftcorrection_graphical(varargin)
% DRIFTCORRECTION_GRAPHICAL - Evaluate or perform manual drift correction on image data
%
%   DRIFTCORRECTION_GRAPHICAL('INPUTS',INPUTS)
%
%   Brings up a graphical user interface for correcting drift
%
%     INPUTS is the standard ANALYZETPSTACK_DRAW_DEVICE input structure with fields
%         dirname                   The dirname being examined
%         fullpathdirname           The full path of the directory being examined
%         refdirname                The parent directory (based on reference.txt file) of
%                                       the directory being examined
%         fullrefdirname            The full path of the parent directory
%         channel                   The channel number on which to perform drift correction
%         ds                        A directory structure object for traversing the
%                                       file structure for the entire experiment.
%         view                      The TPPreview function shortname to be used for the images
%         viewchannel               The channel currently being viewed in the analyzetpstack preview window
%         viewframe                 The frame number currently being viewed in the analyzetpstack preview window
%         viewColorMinMax           The color Min and Max value currently being viewed in the analyzetpstack preview window
%         xyoffset                  A 1x2 matrix with the manual x/y offset for this directory
%         refxyoffset               A 1x2 matrix with the manual x/y offset of the reference directory
%         analyzetpstack_handle     Window handle of current analyzetpstack window



 % to do:  pan, zoom, join axes


command = 'Main'; 
fig = '';
success = 0;
windowheight = 600;
windowwidth = 1000;
windowrowheight = 25;
uiBackgroundColor = 0.94 * [1 1 1];
uiHighlightBackgroundColor = 0.7 * [1 1 1];
markerlist = [];
celllist = [];
driftinfo = [];
frameImage = [];
keyframes = [];

inputs = [];
windowlabel = 'Graphical Drift Correction';

varlist = {'inputs','windowheight','windowwidth','windowrowheight','windowlabel','uiBackgroundColor', ...
		'uiHighlightBackgroundColor',...
		'celllist','markerlist','driftinfo','keyframes','frameImage'};

assign(varargin{:});

if isempty(fig),
	fig = figure('name','Graphical Drift Correction','NumberTitle','off');
end;

 % initialize userdata field
if strcmp(command,'Main'),
	for i=1:length(varlist),
		eval(['ud.' varlist{i} '=' varlist{i} ';']);
	end;
else,
	ud = get(fig,'userdata');
end;

command,

switch command,
	case 'Main',
		if ishandle(ud.inputs.analyzetpstack_handle),
			analyzetpstack_userdata = get(ud.inputs.analyzetpstack_handle,'userdata');
			ud.celllist = analyzetpstack_userdata.celllist;
		end;
		set(fig,'userdata',ud);
		driftcorrection_graphical('command','NewWindow','fig',fig);
		driftcorrection_graphical('command','ReloadBt','fig',fig);
	case 'NewWindow',
		% control object defaults

                % this callback was a nasty puzzle in quotations:
                callbackstr = [  'eval([get(gcbf,''Tag'') ''(''''command'''','''''' get(gcbo,''Tag'') '''''' ,''''fig'''',gcbf);'']);'];
		uidefs = basicuitools_defs('callbackstr',callbackstr);
		uidefs.edit.callback = callbackstr;

		right = ud.windowwidth;
		top = ud.windowheight;
		row = ud.windowrowheight;
		imageWidth = 400;
		imageHeight = 400;

		set(fig,'position',[50 50 right top],'tag','driftcorrection_graphical');

		uicontrol(uidefs.txt,'position',[5 top-2*row right 20],'tag','dirnameTxt',...
				'string',[ud.inputs.fullpathdirname],'horizontalalignment','left');
		uicontrol(uidefs.txt,'position',[5 row*4+imageHeight+5 imageWidth 20],'tag','RefLabelTxt',...
				'horizontalalignment','center','string','Reference image');
		refAxes=axes('units','pixels','position',[5 row*4 imageWidth imageHeight],'tag','refImageAxes'); 
		uicontrol(uidefs.button,'position',[5 row*3 100 20],'string','Zoom','tag','ZoomBt','userdata',0);
		uicontrol(uidefs.button,'position',[5+100+5 row*3 100 20],'string','Pan','tag','PanBt','userdata',0);
		uicontrol(uidefs.cb,'position',[5 row*2 100 20],'string','Show cells:','tag','ShowCellsCB');
		uicontrol(uidefs.cb,'position',[5 row*1 100 20],'string','Show marks:','tag','ShowMarksCB');
		uicontrol(uidefs.button,'position',[5+100+5 row*2 100 20],'string','Add marks','tag','AddMarksBt');
		uicontrol(uidefs.button,'position',[5+100+5 row*1 100 20],'string','Clear marks','tag','ClearMarksBt');
		uicontrol(uidefs.txt,'position',[5+100+5+5+100 row*2 180 20],'tag','ColorEditLabelTxt',...
			'string','ColorScale [min1 max1 min2 max2]','fontsize',10);
		uicontrol(uidefs.edit,'position',[5+100+5+5+100 row*1 180 20],'tag','ColorMinMaxEdit','string','[0 2000 0 2000]');

		uicontrol(uidefs.txt,'position',[5+imageWidth+5 row*4+imageHeight+5 imageWidth 20],'tag','ImageLabelTxt','horizontalalignment','center',...
				'string','Frame image');
		frameAxes=axes('units','pixels','position',[5+imageWidth+5 row*4 imageWidth imageHeight],'tag','frameImageAxes'); 
                uicontrol(uidefs.button,'position',[5+5+imageWidth 1.5*row 20 20],'String','<<','tag','RewindBt','horizontalalignment','center');
                uicontrol(uidefs.button,'position',[5+5+imageWidth+22 1.5*row 20 20],'String','<','tag','ReverseBt','horizontalalignment','center',...
                                'userdata',0);
                uicontrol(uidefs.button,'position',[5+5+imageWidth+22*2 1.5*row 20 20], 'String','>','tag','PlayBt','horizontalalignment','center',...
                                'userdata',0);
                uicontrol(uidefs.button,'position',[5+5+imageWidth+22*3 1.5*row 20 20],'String','>>','tag','FastforwardBt','horizontalalignment','center');
                uicontrol(uidefs.txt,'position',   [5+5+imageWidth 2.5*row 45 20],'string','Frame:','tag','FrameLabelTxt','horizontalalignment','left');
                uicontrol(uidefs.txt,'position',   [5+5+imageWidth+50 2.5*row 50 20],'string','1','tag','FrameSliderTxt','horizontalalignment','right');
                uicontrol(uidefs.slider,'position',[5+5+imageWidth 0.5*row 100 20],'min',1,'max',10,'value',1,'tag','FrameSlider','SliderStep',[1 1]/11);

                uicontrol(uidefs.txt,'position',[5+5+imageWidth+imageWidth/2-100/2 2.5*row 100 20],'String','Drift control:','tag','DriftControlTxt',...
			'horizontalalignment','center');
                uicontrol(uidefs.button,'position',[5+5+imageWidth+imageWidth/2-20/2 1.5*row 20 20],'String','^','tag','UpBt','horizontalalignment','center');
                uicontrol(uidefs.button,'position',[5+5+imageWidth+imageWidth/2-20/2-25 1*row 20 20],'String','<','tag','LeftBt','horizontalalignment','center');
                uicontrol(uidefs.button,'position',[5+5+imageWidth+imageWidth/2+15 1*row 20 20],'String','>','tag','RightBt','horizontalalignment','center');
                uicontrol(uidefs.button,'position',[5+5+imageWidth+imageWidth/2-20/2 0.5*row 20 20],'String','v','tag','DownBt','horizontalalignment','center');
                uicontrol(uidefs.button,'position',[5+5+imageWidth+imageWidth/2+15+10 2*row 20 20],'String','5x','tag','5xBt',...
			'horizontalalignment','center','userdata',0);
                uicontrol(uidefs.button,'position',[5+5+imageWidth+imageWidth/2+15+20+5+50 2.5*row 100 20],'String','Help','tag','HelpBt','visible','on');
                uicontrol(uidefs.cb,'position',[5+5+imageWidth+imageWidth/2+15+20+5+50 1.5*row 100 20],'String','Key frame*','tag','KeyFrameCB','visible','on');
                uicontrol(uidefs.button,'position',[5+5+imageWidth+imageWidth/2+15+20+5+50 0.5*row 100 20],'String','Fill down','tag','FillDownBt');

		uicontrol(uidefs.txt,'position',[5+2*imageWidth+5+5 row*4+imageHeight 130 20],'tag','DriftLabelTxt','horizontalalignment','center',...
				'string','Frame drift');
		uicontrol(uidefs.list,'position',[5+5+2*imageWidth+5 row*4 160 imageHeight],'string','','tag','DriftList','Max',2);
                uicontrol(uidefs.button,'position',[3*5+2*imageWidth+5 2.5*row 125 20],'String','Reload','tag','ReloadBt',...
			'horizontalalignment','center','fontweight','bold');
                uicontrol(uidefs.button,'position',[3*5+2*imageWidth+5 1.5*row 125 20],'String','Save','tag','SaveBt',...
			'horizontalalignment','center','fontweight','bold');
                uicontrol(uidefs.button,'position',[3*5+2*imageWidth+5 0.5*row 125 20],'String','Cancel','tag','CancelBt',...
			'horizontalalignment','center','fontweight','bold');

		linkaxes([refAxes frameAxes],'xy');

	case 'ReloadBt',
		% load and plot reference image
		driftcorrection_graphical('command','UpdateReferenceImage','fig',fig);
		% reset frame counter to 1
		set(ft(fig,'FrameSlider'),'value',1);
		% load driftinfo from disk and make no key frames
		driftcorrection_graphical('command','LoadDriftInfo','fig',fig);
		driftcorrection_graphical('command','UpdateFrameImage','fig',fig);
		driftcorrection_graphical('command','UpdateFrameCounter','fig',fig);
	case 'SaveBt',
		analyzetpstack_setdirdrift(ud.inputs, ud.inputs.dirname, ud.driftinfo);
	case 'CancelBt',
		delete(fig);

	case 'LoadDriftInfo', % writes userdata
		analyzetpstackud = get(ud.inputs.analyzetpstack_handle,'userdata');
		[dr_initial, dr_all_raw, dr_all_offset] = analyzetpstack_getdirdrift(analyzetpstackud,ud.inputs.dirname);
		if isempty(dr_all_raw) | size(dr_all_raw,1)==1,
			[refmnmx,mnmx,channel,view,frame] = driftcorrection_graphical('command','GetSettings','fig',fig);
			[frameImage,params,total_frames] = TPPreviewImageFunctionListGetPreviewImageParams(...
                                ud.inputs.fullpathdirname,ud.inputs.view,ud.inputs.channel,frame);
			dr_all_raw = zeros(total_frames,2);
		end;
		ud.driftinfo = dr_all_raw;
		ud.keyframes = [];
		set(fig,'userdata',ud);
		driftcorrection_graphical('command','UpdateDriftList','fig',fig);

	case 'ColorMinMaxEdit',
		driftcorrection_graphical('command','UpdateReferenceImage','fig',fig);
		driftcorrection_graphical('command','UpdateFrameImage','fig',fig);

	case 'KeyFrameCB',
		f = round(get(ft(fig,'FrameSlider'),'value'));
		if get(ft(fig,'KeyFrameCB'),'value'),
			ud.keyframes = unique([ud.keyframes(:); f]); 
		else
			ud.keyframes = setdiff(ud.keyframes,f);
		end;
		if length(ud.keyframes)==2,
			keyframes = sort(ud.keyframes);
			frameinsert = keyframes(1)+1:keyframes(2)-1;
			keyframes,
			ud.driftinfo(keyframes,1)'
			xnew = round(interp1(keyframes,ud.driftinfo(keyframes,1),frameinsert,'linear'));
			ynew = round(interp1(keyframes,ud.driftinfo(keyframes,2),frameinsert,'linear'));
			ud.driftinfo(frameinsert,[1 2]) = [xnew(:) ynew(:)];
			ud.keyframes = [];
		end;
		set(fig,'userdata',ud);
		driftcorrection_graphical('command','UpdateDriftList','fig',fig);
		driftcorrection_graphical('command','UpdateFrameCounter','fig',fig);
		
        case 'UpdateFrameCounter',
		f = round(get(ft(fig,'FrameSlider'),'value'));
		set(ft(fig,'FrameSliderTxt'),'string',int2str(f)),
		% drift correct list
		set(ft(fig,'FrameSlider'),'value',f);
		set(ft(fig,'DriftList'),'value',f);
		set(ft(fig,'KeyFrameCB'),'value',length(intersect(f,ud.keyframes)));

	case 'UpdateDriftList',
		str = {};
		digits = max(1,ceil(log10(1+size(ud.driftinfo,1))));
		for i=1:size(ud.driftinfo,1),
			if ~isempty(intersect(ud.keyframes,i)),
				kf = '*';
			else,
				kf = ' ';
			end;
			str{i} = [ kf sprintf(['%' int2str(digits) '.d'], i) ' | ' int2str(ud.driftinfo(i,1)) ' ' int2str(ud.driftinfo(i,2))  ]; 
		end;
		set(ft(fig,'DriftList'),'string',str,'max',1,'value',1,'fontname','Courier');

	case 'UpdateReferenceImage',
		refmnmx = driftcorrection_graphical('command','GetSettings','fig',fig);
		refImage = TPPreviewImageFunctionListGetPreviewImageParams(...
                                ud.inputs.fullrefdirname,ud.inputs.view,ud.inputs.channel,0);
		refImage = rescale(double(refImage),refmnmx,[0 255]);
		refAx = findobj(fig,'type','axes','tag','refImageAxes');
		currentaxes = gca;
		axes(refAx);
		oldimage = findobj(refAx,'type','Image');
		if ~isempty(oldimage), delete(oldimage); end;
		refImageHandle = image(refImage);
		set(refImageHandle,'xdata',get(refImageHandle,'xdata')+ud.inputs.refxyoffset(1),'ydata',get(refImageHandle,'ydata')+ud.inputs.refxyoffset(2));
		movetoback(refImageHandle);
		drawnow;
		colormap(gray(256));
		set(refAx,'tag','refImageAxes');
		set(refAx,'box','off','YTick',[],'XTick',[])
		axes(currentaxes); % return current axes to their previous value

	case 'ShowCellsCB',
		axeslist = {'refImageAxes', 'frameImageAxes' };
		for j=1:length(axeslist),
			a = ft(fig,axeslist{j});
			h = findobj(a,'tag','CellDrawing');
			if ~isempty(h), delete(h); end;
			h = findobj(a,'tag','CellText');
			if ~isempty(h), delete(h); end;
			set(a,'tag',axeslist{j});
		end;
		if get(ft(fig,'ShowCellsCB'),'value'), % markers on
			currAxes = gca;
			for j=1:length(axeslist),
				xyoffsets = ud.inputs.refxyoffset;
				if j==2,
					xyoffsets = ud.inputs.xyoffset;
				end;
				h = [];
				a = ft(fig,axeslist{j});
				axes(a);
				hold on;
				for i=1:length(ud.celllist)
					if strcmp(ud.celllist(i).dirname,ud.inputs.refdirname),
						h(end+1) = plot(ud.celllist(i).xi-xyoffsets(1),ud.celllist(i).yi-xyoffsets(2),...
								'b-','tag','CellDrawing','linewidth',2);
						h(end+1) = text(mean(ud.celllist(i).xi)-xyoffsets(1),mean(ud.celllist(i).yi)-xyoffsets(2),...
							int2str(ud.celllist(i).index), 'fontsize', 12, 'fontweight', 'bold', 'tag','CellText');
					end;
				end;
				if ~isempty(h), movetofront(h); end;
				set(a,'tag',axeslist{j});
			end;
			axes(currAxes);
		end;

	case 'ShowMarksCB',
		axeslist = {'refImageAxes', 'frameImageAxes' };
		for j=1:length(axeslist),
			a = ft(fig,axeslist{j});
			h = findobj(a,'tag','Marker');
			if ~isempty(h), delete(h); end;
			set(a,'tag',axeslist{j});
		end;
		if get(ft(fig,'ShowMarksCB'),'value'), % markers on
			currAxes = gca;
			for j=1:length(axeslist),
				h = [];
				a = ft(fig,axeslist{j});
				axes(a);
				hold on;
				for i=1:length(ud.markerlist)
					h(end+1) = plot(ud.markerlist{i}.xi,ud.markerlist{i}.yi,'r-','tag','Marker','linewidth',2);
				end;
				if ~isempty(h), movetofront(h); end;
				set(a,'tag',axeslist{j});
			end;
			axes(currAxes);
		end;

	case 'UpdateFrameImage',
		[refmnmx,mnmx,channel,view,frame] = driftcorrection_graphical('command','GetSettings','fig',fig);
		[frameImage,params,total_frames] = TPPreviewImageFunctionListGetPreviewImageParams(...
                                ud.inputs.fullpathdirname,ud.inputs.view,ud.inputs.channel,frame);
		if get(ft(fig,'FrameSlider'),'max')~=total_frames,
			set(ft(fig,'FrameSlider'),'max',total_frames,'SliderStep',[1 1]/total_frames);
		end;
		frameImage = rescale(double(frameImage),mnmx,[0 255]);
		frameImageAx = findobj(fig,'type','axes','tag','frameImageAxes');
		currentaxes = gca;
		axes(frameImageAx);
		hold on;
		oldimage = findobj(frameImageAx,'type','Image');
		if ~isempty(oldimage), delete(oldimage); end;
		frameImageHandle = image(frameImage);
			% need to add drift info here
		set(frameImageHandle,'xdata',get(frameImageHandle,'xdata')+(-ud.inputs.xyoffset(1)+ud.driftinfo(frame,1)),...
				'ydata',get(frameImageHandle,'ydata')+(-ud.inputs.xyoffset(2))+ud.driftinfo(frame,2));
		movetoback(frameImageHandle);
		drawnow;
		colormap(gray(256));
		set(frameImageAx,'tag','frameImageAxes');
		set(frameImageAx,'box','off','YTick',[],'XTick',[],'ydir','reverse')
		axes(currentaxes); % return current axes to their previous value

	case 'GetSettings',
		try,
			colorminmax = str2num(get(ft(fig,'ColorMinMaxEdit'),'string'));
		catch,
			errordlg(['Syntax error in ColorMinMaxEdit']);
			colorminmax = [ 0 2000 0 2000];
			set(ft(fig,'ColorMinMaxEdit'),'string','[0 2000 0 2000]');
		end;

		currentFrame = round(get(ft(fig,'FrameSlider'),'value'));
		set(ft(fig,'FrameSlider'),'value',currentFrame);

		varargout{1} = colorminmax(1:2);
		varargout{2} = colorminmax(3:4);
		varargout{3} = ud.inputs.channel;
		varargout{4} = ud.inputs.view;
		varargout{5} = currentFrame;
	case 'ZoomBt',
		out = int8(get(ft(fig,'ZoomBt'),'userdata'));
		if out==0,
			set(ft(fig,'ZoomBt'),'userdata',1,'BackgroundColor',0.7*[1 1 1]);
			set(ft(fig,'PanBt'),'userdata',0,'BackgroundColor',0.94*[1 1 1]);
			zoom on;
		else,
			zoom off
			set(ft(fig,'ZoomBt'),'userdata',0,'BackgroundColor',0.94*[1 1 1]);
			set(ft(fig,'PanBt'),'userdata',0,'BackgroundColor',0.94*[1 1 1]);
		end;
	case 'PanBt',
		out = int8(get(ft(fig,'PanBt'),'userdata'));
		if out==0,
			set(ft(fig,'ZoomBt'),'userdata',0,'BackgroundColor',0.94*[1 1 1]);
			set(ft(fig,'PanBt'),'userdata',1,'BackgroundColor',0.7*[1 1 1]);
			pan on;
		else,
			pan off;
			set(ft(fig,'ZoomBt'),'userdata',0,'BackgroundColor',0.94*[1 1 1]);
			set(ft(fig,'PanBt'),'userdata',0,'BackgroundColor',0.94*[1 1 1]);
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
			driftcorrection_graphical('command','UpdateFrameCounter','fig',fig);
			driftcorrection_graphical('command','UpdateFrameImage','fig',fig);
			drawnow;
			if v==mx,
				keepPlaying = 0;
				driftcorrection_graphical('command','PlayBt','fig',fig);
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
			driftcorrection_graphical('command','UpdateFrameCounter','fig',fig);
			driftcorrection_graphical('command','UpdateFrameImage','fig',fig);
			drawnow;
			if v==1,
				keepPlaying = 0;
				driftcorrection_graphical('command','ReverseBt','fig',fig);
			end;
		end;
	case 'RewindBt',
		set(ft(fig,'FrameSlider'),'value',1);
		driftcorrection_graphical('command','UpdateFrameCounter','fig',fig);
		driftcorrection_graphical('command','UpdateFrameImage','fig',fig);
	case 'FastforwardBt',
		mx = get(ft(fig,'FrameSlider'),'max');
		set(ft(fig,'FrameSlider'),'value',mx);
		driftcorrection_graphical('command','UpdateFrameCounter','fig',fig);
		driftcorrection_graphical('command','UpdateFrameImage','fig',fig);
        case 'FrameSlider',
		driftcorrection_graphical('command','UpdateFrameCounter','fig',fig);
		driftcorrection_graphical('command','UpdateFrameImage','fig',fig);
	case 'DriftList',
		v = get(ft(fig,'DriftList'),'value');
		set(ft(fig,'FrameSlider'),'value',v);
		driftcorrection_graphical('command','UpdateFrameCounter','fig',fig);
		driftcorrection_graphical('command','UpdateFrameImage','fig',fig);
	case {'UpBt','DownBt','LeftBt','RightBt'},
		stepsize = 1 + 4 * (get(ft(fig,'5xBt'),'userdata'));
		dx = 0;
		dy = 0;
		if strcmp(command,'UpBt'),   dy = -stepsize; end;
		if strcmp(command,'DownBt'), dy = +stepsize; end;
		if strcmp(command,'LeftBt'), dx = +stepsize; end;
		if strcmp(command,'RightBt'),dx = -stepsize; end;
		frame = get(ft(fig,'FrameSlider'),'value');
		ud.driftinfo(frame,:) = ud.driftinfo(frame,:) + [dx dy];
		set(fig,'userdata',ud);
		driftcorrection_graphical('command','UpdateDriftList','fig',fig);
		driftcorrection_graphical('command','UpdateFrameCounter','fig',fig);
		driftcorrection_graphical('command','UpdateFrameImage','fig',fig);
	case 'FillDownBt',
		frame = get(ft(fig,'FrameSlider'),'value');
		ud.driftinfo(frame+1:end,:) = repmat(ud.driftinfo(frame,:),size(ud.driftinfo,1)-(frame+1)+1,1);
		indexes = find(ud.keyframes<=frame);
		ud.keyframes = ud.keyframes(indexes);
		set(fig,'userdata',ud);
		driftcorrection_graphical('command','UpdateDriftList','fig',fig);
		driftcorrection_graphical('command','UpdateFrameCounter','fig',fig);

	case 'AddMarksBt',
		buttonName = questdlg(['Use the mouse to click on mark locations. Hit <return> when finished.'],'Confirm',...
			'OK','Cancel','OK');
		if ~strcmp(buttonName,'OK'), return; end;
		set(ft(fig,'ShowMarksCB'),'value',1);
		driftcorrection_graphical('command','ShowMarksCB','fig',fig);
		
		x1 = [-10 10]; y1 = [   0  0 ];
		x2 = [  0  0]; y2 = [ -10 10 ];
		[x,y] = ginput(1);
		while ~isempty(x),
			if isempty(ud.markerlist),
				ud.markerlist{1} = struct('xi', x1+x, 'yi', y1+y);
				ud.markerlist{2} = struct('xi', x2+x, 'yi', y2+y);
			else,
				ud.markerlist{end+1} = struct('xi', x1+x, 'yi', y1+y);
				ud.markerlist{end+1} = struct('xi', x2+x, 'yi', y2+y);
			end;
			set(fig,'userdata',ud);
			ud.markerlist,
			driftcorrection_graphical('command','ShowMarksCB','fig',fig);
			ud = get(fig,'userdata');
			[x,y] = ginput(1);
		end;	

	case 'ClearMarksBt',
		buttonName = questdlg(['Clear all marks. Are you sure? '],'Are you sure?',...
			'Yes','Cancel','Yes');
		if ~strcmp(buttonName,'Yes'), return; end;
		set(ft(fig,'ShowMarksCB'),'value',0);
		ud.markerlist = [];
		set(fig,'userdata',ud);
		driftcorrection_graphical('command','ShowMarksCB','fig',fig);

	case '5xBt',
		v = 1-get(ft(fig,'5xBt'),'userdata');
		set(ft(fig,'5xBt'),'userdata',v);
		if v,
			set(ft(fig,'5xBt'),'BackgroundColor',0.7*[1 1 1]);
		else,
			set(ft(fig,'5xBt'),'BackgroundColor',0.94*[1 1 1]);
		end;

	case 'HelpBt',
		msg = text2cellstr('driftcorrection_graphical_help.txt');
		msgbox(msg,'driftcorrection_graphical help');

	otherwise,
		error(['Unknown command: ' command '.']);
end;


function obj = ft(fig, name)
obj = findobj(fig,'Tag',name);

