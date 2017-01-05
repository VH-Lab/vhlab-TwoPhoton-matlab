function out = analyzetpstack_drift_devs_menu(command, uihandle, inputs)

out = [];

switch lower(command),

	case 'init',
		dd = analyzetpstack_drift_devices('Get');
		ad = analyzetpstack_active_drift_devices('Get');

		ud = {[] [] []};

		str = {'Drift Correction','Update this list','-----'};

		ud{end+1} = [];
		str{end+1} = 'Use device:';

		for i=1:length(ad),
			ud{end+1} = ad(i);
			str{end+1} = ad(i).DriftDevicesName;
		end;

		ud{end+1} = [];
		ud{end+1} = [];
		str{end+1} = '-----';
		str{end+1} = 'Add a new active device:';

		for i=1:length(dd),
			ud{end+1} = i;
			str{end+1} = dd(i).DriftDevicesFuncName;
		end;

		set(uihandle,'string',str,'userdata',ud,'value',1);
		
	case 'handleclick',
		v = get(uihandle,'value');
		ud = get(uihandle,'userdata');
		str = get(uihandle,'string');

		if v==1,  % this is just the title, do nothing
		elseif v==2, % this is the update command
			celllist = [];
			analyzetpstack_drift_devs_menu('init',uihandle);
		else,
			ud{v},
			if isnumeric(ud{v})
				analyzetpstack_drift_devices('Activate',ud{v}),
			elseif isstruct(ud{v}),
				celllist = analyzetpstack_active_drift_devices('Call',ud{v}.DriftDevicesName,inputs);
			end;
		end;

		set(uihandle,'value',1); % end on the title
end;
