function tplinescandriftexplorer (varargin)
% TPLINESCANDRIFTEXPLORER - Explore the effect of XY drift on linescans
%
%   TPLINESCANDRIFTEXPLORER('DIRNAME', DIRNAME,...
%      'RASTERIMAGE', RASTERIMAGE,  ...
%	'LINESCANPOINTS', LINESCANPOINTS, ...
%	'UNCORRECTEDLINESCANIMAGE',UNCORRECTEDLINESCANIMAGE, 
%       'DEFAULTDRIFT', [DX DY]);
%
%   Brings up a graphical user interface to allow the user to explore the effect
%   of XY drift on 2-photon linescans
%
%   DIRNAME should be the full path name of the directory being examined.
%   RASTERIMAGE should be the image of the raster image
%   LINESCANPOINTS is an Nx2 linescan path
%   UNCORRECTEDLINESCANIMAGE is the image of the uncorrected linescan image.
%   DEFAULTDRIFT is the default drift that should be used for shifting the linescan path

  % add number of spikes to cluster info, compute mean waveforms
   
 % internal variables, for the function only
command = 'Main';    % internal variable, the command
fig = '';                 % the figure
success = 0;
windowheight = 800;
windowwidth = 1100;
windowrowheight = 35;
rasterimage = [];
linescanpoints = [];
defaultdrift = [0 0];
uncorrectedlinescanimage = [];

 % user-specified variables
dirname = '';
windowlabel = 'TP Linescan Drift Explorer';

varlist = {'dirname','windowheight','windowwidth','windowrowheight','windowlabel','defaultdrift','linescanpoints','rasterimage','uncorrectedlinescanimage'};

assign(varargin{:});

if isempty(fig),
	fig = figure;
end;

 % initialize userdata field
if strcmp(command,'Main'),
	for i=1:length(varlist),
		eval(['ud.' varlist{i} '=' varlist{i} ';']);
	end;
else,
	ud = get(fig,'userdata');
end;

%command,

switch command,
	case 'Main',
		ud.drift = ud.defaultdrift;
		set(fig,'userdata',ud);
		tplinescandriftexplorer('command','NewWindow','fig',fig);
		tplinescandriftexplorer('command','Update','fig',fig);
	case 'NewWindow',
		% control object defaults
		% this callback was a nasty puzzle in quotations:
		callbackstr = [  'eval([get(gcbf,''Tag'') ''(''''command'''','''''' get(gcbo,''Tag'') '''''' ,''''fig'''',gcbf);'']);']; 

		button.Units = 'pixels';
                button.BackgroundColor = [0.8 0.8 0.8];
                button.HorizontalAlignment = 'center';
                button.Callback = callbackstr;
                txt.Units = 'pixels'; txt.BackgroundColor = [0.8 0.8 0.8];
                txt.fontsize = 12; txt.fontweight = 'normal';
                txt.HorizontalAlignment = 'left';txt.Style='text';
                edit = txt; edit.BackgroundColor = [ 1 1 1]; edit.Style = 'Edit';
		edit.callback = callbackstr;
                popup = txt; popup.style = 'popupmenu';
                popup.Callback = callbackstr;
		list = txt; list.style = 'list';
		list.Callback = callbackstr;
                cb = txt; cb.Style = 'Checkbox';
                cb.Callback = callbackstr;
                cb.fontsize = 12;

		right = ud.windowwidth;
		top = ud.windowheight;
		row = ud.windowrowheight;

                set(fig,'position',[50 50 right top],'tag','tplinescandriftexplorer');
		uicontrol(txt,'position',[5 top-row*1 600 30],'string',ud.windowlabel,'horizontalalignment','left','fontweight','bold');
		uicontrol(txt,'position',[5 top-row*2 600 30],'string',[ud.dirname]);
		
		ax_image = axes('units','pixels','position',[30 top-row*2-500-30 500 500],'tag','imageAx');
		ax_shiftedlinescan = axes('units','pixels','position',[580 top-row*2-200-30 500 200],'tag','shiftedlinescanAx');
		ax_reallinescan = axes('units','pixels','position',[580 top-row*2-500-30 500 200],'tag','reallinescanAx');

		uicontrol(txt,'position',[10 top-row*19 100 30],'string','Drift [Y X]:','tag','driftTitleTxt');
		uicontrol(edit,'position',[10+100+5 top-row*19 100 30+3],'string',['[ ' int2str(ud.defaultdrift(1)) ' '  int2str(ud.defaultdrift(2)) ' ]'],...
					'tag','driftEdit','horizontalalignment','center');
		uicontrol(txt,'position',[10 top-row*20 300 30],...
					'string',['Drift correct found: [ ' int2str(ud.defaultdrift(1)) ' ' int2str(ud.defaultdrift(2))  ' ]'],...
					'tag','driftTitleTxt');
		uicontrol(button,'position',[580 top-row*19 100 30],'string','Match XAxis','tag','MatchXAxisBt');
		uicontrol(txt,'position',[580 top-row*10.5 400 30],'string','Red indicates any points that are out of bounds after the shift',...
			'tag','RedLabelTxt','ForegroundColor',[1 0 0],'fontsize',10);
		uicontrol(button,'position',[30+500-100 top-row*19 100 30],'string','Redraw Edges','tag','RedrawEdgesBt');

		set(fig,'userdata',ud);
	case 'Update',
		% redraw everything
		tplinescandriftexplorer('fig',fig,'command','DrawRaster');
		tplinescandriftexplorer('fig',fig,'command','DrawUncorrectedLinescan');
		tplinescandriftexplorer('fig',fig,'command','DrawDriftCorrectedLinescan');
		tplinescandriftexplorer('fig',fig,'command','DrawEdges');
	case 'DrawRaster',
		maxvalue = max(ud.rasterimage(:));
		minvalue = min(ud.rasterimage(:));
		img = rescale(ud.rasterimage,[minvalue maxvalue],[0 254]);
		ax_image = findobj(fig,'tag','imageAx');
		current_ax = gca;
		axes(ax_image);
		cla;
		image(img);
		colormap([gray(255) ; [1 0 0]]);
		hold on;
		plot(ud.linescanpoints(:,1),ud.linescanpoints(:,2),'y-','linewidth',2,'tag','uncorrectlinescan');
		set(ax_image,'tag','imageAx');
		axes(current_ax);  % return the current axes when we are done drawing
	case 'MatchXAxisBt',
		current_ax = gca;
		ax_reallinescan = findobj(fig,'tag','reallinescanAx');
		ax_shiftedlinescan = findobj(fig,'tag','shiftedlinescanAx');
		if any(current_ax==[ax_reallinescan ax_shiftedlinescan]),
			% if user clicked in something on this page
			A=axis;
			axes(ax_reallinescan);
			A2=axis;
			axis([A([1 2]) A2(3) A2(4)]);
			axes(ax_shiftedlinescan);
			A2=axis;
			axis([A([1 2]) A2(3) A2(4)]);
			axes(current_ax);
			tplinescandriftexplorer('fig',fig,'command','DrawEdges');
		else,
			errordlg(['Please click in one of the linescan axes to make those axes current, and try again.']);
		end;
	case {'DrawEdges','RedrawEdgesBt'},
		current_ax = gca;

		ax_reallinescan = findobj(fig,'tag','reallinescanAx');
		xreal = round(get(ax_reallinescan,'XLim'));
		if xreal(1)<1, xreal(1) = 1; end;
		if xreal(2)>size(ud.linescanpoints,1), xreal(2) = size(ud.linescanpoints,1); end;

		ax_shiftedlinescan = findobj(fig,'tag','shiftedlinescanAx');
		xshift = round(get(ax_shiftedlinescan,'XLim'));
		if xshift(1)<1, xshift(1) = 1; end;
		if xshift(2)>size(ud.linescanpoints,1), xshift(2) = size(ud.linescanpoints,1); end;

		ax_image = findobj(fig,'tag','imageAx');
		axes(ax_image);
		tags = {'uncorrectlinescanbeginning','uncorrectedlinescanend','correctedlinescanbeginning','correctedlinescanend'};
		% delete any existing
		for i=1:length(tags),
			try,
				delete(findobj(ax_image,'tag',tags{i}));
			end;
		end;

		% look at actual recorded linescan view
		
		hold on;
		plot(ud.linescanpoints(xreal(1),1),ud.linescanpoints(xreal(1),2),'yo','markersize',10,'tag',tags{1});
		plot(ud.linescanpoints(xreal(2),1),ud.linescanpoints(xreal(2),2),'y^','markersize',10,'tag',tags{2});
		plot(ud.linescanpoints(xshift(1),1)-ud.drift(2),ud.linescanpoints(xshift(1),2)-ud.drift(1),'bo','markersize',10,'tag',tags{3});
		plot(ud.linescanpoints(xshift(2),1)-ud.drift(2),ud.linescanpoints(xshift(2),2)-ud.drift(1),'b^','markersize',10,'tag',tags{4});
		axes(current_ax);
	case 'DrawUncorrectedLinescan',
		maxvalue = max(ud.rasterimage(:));
		minvalue = min(ud.rasterimage(:));
		img = rescale(ud.uncorrectedlinescanimage,[minvalue maxvalue],[0 254]);
		current_ax = gca;
		ax_reallinescan = findobj(fig,'tag','reallinescanAx');
		axes(ax_reallinescan);
		A = axis;
		image(img);
		colormap([gray(255) ; [1 0 0]]);
		title('Actual recorded linescan');
		set(ax_reallinescan,'tag','reallinescanAx');
		if ~eqlen(A([1 2]),[0 1]), % restore any previous X axis
			B = axis;
			axis([A([1 2]) B([3 4])]);
		end;
		axes(current_ax);  % return the current axes when we are done drawing
	case 'DrawDriftCorrectedLinescan',
		% determine the shifted scan
		imsize = size(ud.rasterimage);
		inds = linescan2rasterindex(imsize,[ud.linescanpoints(:,1)-ud.drift(2) ud.linescanpoints(:,2)-ud.drift(1)]);
		goodinds = find(inds>1&~isnan(inds));
		imscan = nan(size(inds))';
		imscan(goodinds) = ud.rasterimage(inds(goodinds));
		% rescale the image
		maxvalue = max(ud.rasterimage(:));
		minvalue = min(ud.rasterimage(:));
		img = rescale(imscan,[minvalue maxvalue],[0 254]);
		img(find(isnan(imscan))) = 256;
		% plot the image on the correct axes
		current_ax = gca;
		ax_shiftedlinescan = findobj(fig,'tag','shiftedlinescanAx');
		axes(ax_shiftedlinescan);
		A = axis;
		image(img);
		colormap([gray(255) ; [1 0 0]]);
		title('What shifted linescan should look like');
		set(ax_shiftedlinescan,'tag','shiftedlinescanAx');
		if ~eqlen(A([1 2]),[0 1]), % restore any previous X axis
			B = axis;
			axis([A([1 2]) B([3 4])]);
		end;
		% plot the linesan line 
		ax_image = findobj(fig,'tag','imageAx');
		axes(ax_image);
		existing_plot = findobj(ax_image,'tag','shiftedlinescan');
		if ~isempty(existing_plot), try, delete(existing_list); end; end;
		hold on;
		% dont feel good about this -- why are drift(1) and linescanpoints(:,2) together??
		plot(ud.linescanpoints(:,1)-ud.drift(2),ud.linescanpoints(:,2)-ud.drift(1),'b','linewidth',1,...
			'tag','shiftedlinescan');
		axes(current_ax);  % return the current axes when we are done drawing
	case 'driftEdit',
		driftstr = get(findobj(fig,'tag','driftEdit'),'string');
		ud.drift = str2num(driftstr);
		set(fig,'userdata',ud);
		tplinescandriftexplorer('fig',fig,'command','Update');
end;
