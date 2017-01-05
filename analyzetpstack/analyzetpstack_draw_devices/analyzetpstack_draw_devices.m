function [output,output2] = analyzetpstack_draw_devices(command, arg2, arg3, arg4)

% ANALYZETPSTACK_DRAW_DEVICES - Register/Remove/Get draw devices
%
%   This function Registers, Removes, or Gets the draw devices for
%   analyzetpstack.  By being added to this list, these draw
%   devices are identified to analyzetpstack as being available
%   for subsequent configuration and addition to the 
%   ANALYZETPSTACK_ACTIVE_DRAW_DEVICES (the ones that can be
%   chosen directly in ANALYZETPSTACK).
%
%   Usages:
%  
%   O=ANALYZETPSTACK_DRAW_DEVICES('Register', DrawDevicesFuncName);
%       When called with no arguments, DrawDevicesFuncName should 
%       allow the user to specify the parameters of DrawDevicesFuncName graphically. 
%
%   O=ANALYZETPSTACK_DRAW_DEVICES('Activate', indexnumber) adds the
%         DrawDevice to the active list analyzetpstack_active_draw_devices.
%         In order to determine the parameters, the DrawDevicesParameterFunctionName
%         is called.
%
%   O=ANALYZETPSTACK_DRAW_DEVICES('Get') returns a structure
%         list of all registered devices.
%
%   O=ANALYZETPSTACK_DRAW_DEVICES('Remove', indexnumber_or_name)
%         removes the list index number "indexnumber".
%         Use the 'Get' function above to examine the list.
%
%   In all these cases, the output O is the current analyzetpstack_draw_devices list.
%
%   [struct_entry, index] = ANALYZETPSTACK_DRAW_DEVICES('Find', name);
%

analyzetpstack_globals;

output2 = [];

switch lower(command),

	case 'register',
		try, analyzetpstack_draw_devices('Remove',arg2); end;
		s = emptydrawdevicesstruct;
		s.DrawDevicesFuncName = arg2;
		if isempty(analyzetpstack_draw_devs),
			analyzetpstack_draw_devs = s;
		else, analyzetpstack_draw_devs(end+1) = s;
		end;
		output = analyzetpstack_draw_devs;
	case 'get',
		% the output does the job automatically
		output = analyzetpstack_draw_devs;
	case 'remove',
		if ischar(arg2),
			[s,indnumber] = analyzetpstack_draw_devices('Find',arg2);
		else,
			indnumber = arg2;
		end;
		if ~isempty(indnumber),
			analyzetpstack_draw_devs = analyzetpstack_draw_devs([1:indnumber-1 indnumber+1:end]);
		end;
		output = analyzetpstack_draw_devs;
	case 'find',
		index = []; mystruct = [];
		name = arg2;
		for i=1:length(analyzetpstack_draw_devs),
			if strcmp(name,analyzetpstack_draw_devs(i).DrawDevicesFuncName),
				index = i;
				mystruct = analyzetpstack_draw_devs(i);
				break;
			end;
		end;	
		output = mystruct;
		output2 = index;
	case 'activate',
		output = analyzetpstack_draw_devs;
		indnumber = arg2;
		s = analyzetpstack_draw_devs(indnumber);
		parameters = [];
		eval(['parameters = ' s.DrawDevicesFuncName ';']);
		if ~isempty(parameters),
			answer=inputdlg({'Enter a name for this device (no spaces/punctuation)'},'Name',1,{'MyDevice'});
			if ~isempty(answer{1}),
				analyzetpstack_active_draw_devices('Add',answer{1},s.DrawDevicesFuncName,parameters);
			end;
		end;
	otherwise,
		error(['Unknown command input ' command '.']);
end;

	
function s=emptydrawdevicesstruct

s = struct('DrawDevicesFuncName','');
