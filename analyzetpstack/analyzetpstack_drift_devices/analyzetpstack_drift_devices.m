function [output,output2] = analyzetpstack_drift_devices(command, arg2, arg3, arg4)

% ANALYZETPSTACK_DRIFT_DEVICES - Register/Remove/Get drift devices
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
%   O=ANALYZETPSTACK_DRIFT_DEVICES('Register', DriftDevicesFuncName);
%       When called with no arguments, DriftDevicesFuncName should 
%       allow the user to specify the parameters of DriftDevicesFuncName graphically. 
%
%   O=ANALYZETPSTACK_DRIFT_DEVICES('Activate', indexnumber) adds the
%         DriftDevice to the active list analyzetpstack_active_drift_devices.
%         In order to determine the parameters, the DriftDevicesParameterFunctionName
%         is called.
%
%   O=ANALYZETPSTACK_DRIFT_DEVICES('Get') returns a structure
%         list of all registered devices.
%
%   O=ANALYZETPSTACK_DRIFT_DEVICES('Remove', indexnumber_or_name)
%         removes the list index number "indexnumber".
%         Use the 'Get' function above to examine the list.
%
%   In all these cases, the output O is the current analyzetpstack_drift_devices list.
%
%   [struct_entry, index] = ANALYZETPSTACK_DRIFT_DEVICES('Find', name);
%

analyzetpstack_globals;

output2 = [];

switch lower(command),

	case 'register',
		try, analyzetpstack_drift_devices('Remove',arg2); end;
		s = emptydriftdevicesstruct;
		s.DriftDevicesFuncName = arg2;
		if isempty(analyzetpstack_drift_devs),
			analyzetpstack_drift_devs = s;
		else, analyzetpstack_drift_devs(end+1) = s;
		end;
		output = analyzetpstack_drift_devs;
	case 'get',
		% the output does the job automatically
		output = analyzetpstack_drift_devs;
	case 'remove',
		if ischar(arg2),
			[s,indnumber] = analyzetpstack_drift_devices('Find',arg2);
		else,
			indnumber = arg2;
		end;
		if ~isempty(indnumber),
			analyzetpstack_drift_devs = analyzetpstack_drift_devs([1:indnumber-1 indnumber+1:end]);
		end;
		output = analyzetpstack_drift_devs;
	case 'find',
		index = []; mystruct = [];
		name = arg2;
		for i=1:length(analyzetpstack_drift_devs),
			if strcmp(name,analyzetpstack_drift_devs(i).DriftDevicesFuncName),
				index = i;
				mystruct = analyzetpstack_drift_devs(i);
				break;
			end;
		end;	
		output = mystruct;
		output2 = index;
	case 'activate',
		output = analyzetpstack_drift_devs;
		indnumber = arg2;
		s = analyzetpstack_drift_devs(indnumber);
		parameters = [];
		eval(['parameters = ' s.DriftDevicesFuncName ';']);
		if ~isempty(parameters),
			answer=inputdlg({'Enter a name for this device (no spaces/punctuation)'},'Name',1,{'MyDevice'});
			if ~isempty(answer{1}),
				analyzetpstack_active_drift_devices('Add',answer{1},s.DriftDevicesFuncName,parameters);
			end;
		end;
	otherwise,
		error(['Unknown command input ' command '.']);
end;

	
function s=emptydriftdevicesstruct

s = struct('DriftDevicesFuncName','');
