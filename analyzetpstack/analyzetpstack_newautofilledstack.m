function analyzetpstack_newautofilledstack(ds)
% ANALYZETPSTACK_NEWAUTOFILLEDSTACK - Create an autofilled analyzetpstack record
%
%  ANALYZETPSTACK_NEWAUTOFILLEDSTACK(DS)
%
%  This function takes as input a DIRSTRUCT object for the directory of interest,
%  and prompts the user to help 'auto-fill' the stack.
%
%  The user is first asked whether they prefer to create the stack from
%  a set of name and reference pairs, or rather by using the beginning of
%  the name of each subdirectory within the experiment directory indicated
%  by DS.
%
% See also: TWOPHOTONBULKLOAD, ANALYZETPSTACK, DIRSTRUCT

gd = 1;

if gd, % method to add slices automatically

	stacks = {};

	main_slice = {};

	nr = getallnamerefs(ds);
	nrstr = {};
	for i=1:length(nr),
		nrstr{i} = [nr(i).name ' | ' int2str(nr(i).ref) ];
	end;
	if isempty(nr),
		errordlg(['No name/ref pairs found.']);
		error(['No name/ref pairs found.']);
	end;

	s = 1;
	t = 1:length(nr);
	while ~isempty(s)&~isempty(t),
		
		[s,v] = listdlg('PromptString','Select the name/ref pairs to include:',...
                      'SelectionMode','multiple', 'ListString',nrstr(t));
		if ~isempty(s),
			stacks{end+1} = nr(t(s));
			t = setdiff(t,t(s));
		end;
		nrstr{t},
	end;

	% need to pick the directory (maybe the channel?  maybe not) where cell drawing will occur
end;

if gd, % correct drift?
	driftQuest = {'Yes - Ch1', 'Yes - Ch2','Yes - Ch3', 'Yes - Ch4', 'No'};

	[drift_s,drift_v] = listdlg('PromptString','Correct drift?:',...
                      'SelectionMode','single',...
                      'ListString',driftQuest)

	if ~isempty(drift_s),
		CorrectDrift = driftQuest{drift_s};
	else, 
		CorrectDrift = 'Cancel';
	end;

	drift_chan = 1;
	if strcmp(CorrectDrift,'Cancel'),
		gd = 0;
	else,
		switch CorrectDrift,
			case 'No',
				drift_chan = 0;
			case 'Yes - Ch1',
				drift_chan = 1;
			case 'Yes - Ch2',
				drift_chan = 2;
			case 'Yes - Ch3',
				drift_chan = 3;
			case 'Yes - Ch4',
				drift_chan = 4;
		end;
	end;
end;

if gd,  % are we auto-drawing cells?
	autodrawmethod = [];
	liststr = {};
	DrawCells=questdlg('Do you want to auto-draw cells?', ...
		'Auto-draw?', 'Yes', 'No', 'Cancel', 'No');

	if strcmp(DrawCells,'Cancel'),
		gd = 0;
	end;

	if strcmp(DrawCells,'Yes'),
		ad = analyzetpstack_active_draw_devices('Get');
		for i=1:length(ad),
			liststr{end+1} = ad(i).DrawDevicesName;
                end;
		[s,v] = listdlg('PromptString','Select a method:', 'SelectionMode','single',...
                      'ListString',liststr)
		if ~isempty(s),
			autodrawmethod = ad(s);
		end;
	end;
end;

autoanalyze_chan = 0;
if gd&~isempty(autodrawmethod), % auto-analyze?
        aaQuest = {'Yes - Ch1', 'Yes - Ch2','Yes - Ch3', 'Yes - Ch4', 'No'};

	[aa_s,aa_v] = listdlg('PromptString','Automatically analyze data?',...
		'SelectionMode','single', 'ListString',aaQuest);

	if ~isempty(aa_s),
		AutoAnalyze = aaQuest{aa_s};
	else, 
		AutoAnalyze = 'Cancel';
	end;

	if strcmp(AutoAnalyze,'Cancel'),
		gd = 0;
	else,
		switch AutoAnalyze,
			case 'No',
				autoanalyze_chan = 0;
			case 'Yes - Ch1',
				autoanalyze_chan = 1;
			case 'Yes - Ch2',
				autoanalyze_chan = 2;
			case 'Yes - Ch3',
				autoanalyze_chan = 3;
			case 'Yes - Ch4',
				autoanalyze_chan = 4;
		end;
	end;
end;

diary_filename = [];
diary_pathname = [];

if gd, % diary file
	[diary_filename, diary_pathname] = uiputfile('*.txt', 'Save output progress as...');
end;


if gd,  % do it!

	if ~isempty(diary_filename),
		diary([diary_pathname filesep diary_filename]);
		diary on;
	end;

	%try,
		figs = {};

		disp(['<<<-----------------NOW ABOUT TO CREATE ALL STACKS----------------->>>']);

		for i=1:length(stacks),

			disp(['<<<-----------------NOW ABOUT TO CREATE STACK ' int2str(i) '----------------->>>']);

			% 1 - add all the slices to the stack
			
			dirs = {};
			for j=1:length(stacks{i}),
				newdirs = gettests(ds,stacks{i}(j).name,stacks{i}(j).ref);
				dirs = cat(1,dirs,newdirs);
			end;

			analyzetpstack(getpathname(ds),['Stack ' int2str(i)]);
			figs{i} = gcf;

			analyzetpstack_slicelist('Add',[],figs{i},dirs);


			% 2 - if necessary, correct drift for all directories

			if drift_chan>0,
				disp(['<<<-----------------NOW ABOUT TO CORRECT DRIFT FOR STACK ' int2str(i) '----------------->>>']);
				analyzetpstack_correctdriftall(figs{i}, drift_chan);
			end;		

			% 3 - if necessary, auto-draw cells
			
			if ~isempty(autodrawmethod),
				autodraw = findobj(figs{i},'Tag','autoDrawCellsPopup');
				menustr = get(autodraw,'string');
				match = 0;
				for zz=1:length(menustr),
					if strcmp(autodrawmethod.DrawDevicesName,menustr{zz}),
						match = zz;
						break;
					end;
				end;
				if match>0,
					disp(['<<<-----------------NOW ABOUT TO AUTODRAW CELLS FOR STACK ' int2str(i) '----------------->>>']);
					set(autodraw,'value',match);
					analyzetpstack('autoDrawCellsPopup',[],figs{i});
				else, 
					error(['Could not find autodraw method ' autodrawmethod.DrawDeviceName ' in the analyzetpstack menubar.']);
				end;
			end;

			analyzetpstack('saveBt',[],figs{i});

			% 4 - if necessary, perform analysis

			if autoanalyze_chan>0,
				disp(['<<<-----------------NOW ABOUT TO AUTO ANALYZE CELLS FOR STACK ' int2str(i) '----------------->>>']);
				analyzetpstack_analyzerawall(figs{i}, autoanalyze_chan);
			end;

			disp(['<<<-----------------NOW FINISHED WITH STACK ' int2str(i) '----------------->>>']);
		end;

	%catch,
	%	diary off;
	%	error([lasterr]);
	%end;

	diary off;
	disp(['<<<-----------------DIARY (LOG FILE) CLOSED----------------->>>']);

end;

