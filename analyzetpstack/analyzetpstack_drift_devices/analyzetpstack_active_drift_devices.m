function [output,output2] = analyzetpstack_active_drift_devices(command, arg2, arg3, arg4)

% ANALYZETPSTACK_ACTIVE_DRIFT_DEVICES - Add/Remove/Get drift devices
%
%   This function Registers, Removes, or Gets the drift devices for
%   analyzetpstack.  By being added to this list, these drift
%   devices are identified to analyzetpstack as being available
%   for subsequent configuration and addition to the 
%   ANALYZETPSTACK_ACTIVE_DRIFT_DEVICES (the ones that can be
%   chosen directly in ANALYZETPSTACK).
%
%   Usages:
%  
%   O=ANALYZETPSTACK_ACTIVE_DRIFT_DEVICES('Add', DriftDevicesFuncName, ...
%              DriftDevicesParameters, DriftDevicesFuncFlags);
%
%   O=ANALYZETPSTACK_ACTIVE_DRIFT_DEVICES('Get') returns a structure
%         list of all active devices.
%
%   O=ANALYZETPSTACK_ACTIVE_DRIFT_DEVICES('Remove', name_or_indexnumber)
%         removes the list index number "indexnumber".
%         Use the 'Get' function above to examine the list.
%
%   In all cases above, the output O is the current analyzetpstack_active_drift_devs list.
%
%   [DEVICESTRUCT, INDEX] =ANALYZETPSTACK_ACTIVE_DRIFT_DEVICES('Find',NAME)
%         Returns the INDEX number of the device with name NAME;
%         returns empty if it doesn't exist.
%  
%   CELLLIST = ANALYZETPSTACK_ACTIVE_DRIFT_DEVICES('Call', indexnumber_or_name, inputs)
%       Calls a drift device S (specified by the index number of name) using:
%           CELLLIST = S.DriftDevicesFuncName(S.DriftDevicesFuncParameters,inputs);
% 
%   

output = []; output2 = [];

analyzetpstack_globals;

switch lower(command),

	case 'add',
		try, analyzetpstack_active_drift_devices('Remove',arg2); end;
		s = emptyactivedriftdevicesstruct;
		s.DriftDevicesName = arg2;
		s.DriftDevicesFuncName = arg3;
		s.DriftDevicesParameters= arg4;
		if isempty(analyzetpstack_active_drift_devs),
			analyzetpstack_active_drift_devs = s;
		else, analyzetpstack_active_drift_devs(end+1) = s;
		end;
		output = analyzetpstack_active_drift_devs;
	case 'get',
		output = analyzetpstack_active_drift_devs;
	case 'remove',
		if ischar(arg2),
			[s,indnumber] = analyzetpstack_active_drift_devices('Find',arg2);
		else,
			indnumber = arg2;
		end;
		if ~isempty(indnumber),
			analyzetpstack_active_drift_devs = analyzetpstack_active_drift_devs([1:indnumber-1 indnumber+1:end]);
		end;
		output = analyzetpstack_active_drift_devs;
	case 'find',
		index = []; mystruct = [];
		name = arg2;
		for i=1:length(analyzetpstack_active_drift_devs),
			if strcmp(analyzetpstack_active_drift_devs(i).DriftDevicesName,name),
				index = i;
				mystruct = analyzetpstack_active_drift_devs(i);
				break;
			end;
		end;
		output = mystruct;
		output2 = index;
	case 'call',
		if ischar(arg2), % need to find the record of interest
			s = analyzetpstack_active_drift_devices('Find',arg2);
		else,
			index = arg2;
			s = analyzetpstack_active_drift_devices(index);
		end;
		output = eval([s.DriftDevicesFuncName '(s.DriftDevicesParameters,arg3);']);
	otherwise,
		error(['Unknown command input ' command '.']);
end;


function s=emptyactivedriftdevicesstruct

s = struct('DriftDevicesName','','DriftDevicesFuncName','','DriftDevicesParameters',[]);
