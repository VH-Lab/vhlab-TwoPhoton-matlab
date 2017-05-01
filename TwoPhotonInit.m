function TwoPhotonInit

TwoPhotonPath = which('TwoPhotonInit');
pi = find(TwoPhotonPath==filesep);
TwoPhotonPath = [TwoPhotonPath(1:pi(end)) ];

global TwoPhotonPlatform TwoPhotonSynchronization

TwoPhotonConfigurationSuccessful = 0;

try,
	TwoPhotonConfiguration;
	TwoPhotonConfigurationSuccessful = 1;
catch,
	% either it did not exist or had an error
	z = which('TwoPhotonConfiguration');
	if ~isempty(z),
		msgbox(['Error in ' z '; you will be prompted to re-initialize this file. This likely occurred because of a software upgrade or an attempt by the user to edit the TwoPhotonConfiguration.m file manually.']);
	end;
end;

if ~VerifyTwoPhotonConfiguration | ~TwoPhotonConfigurationSuccessful,
	TwoPhotonConfigurationInterview;
	z = which('TwoPhotonConfiguration');
	TwoPhotonConfiguration;
end;

 % check for TwoPhotonUserInit

mypwd = which('TwoPhotonUserInit');

if isempty(mypwd),
	configpath = config_dirname;

	disp(['No TwoPhotonUserInit file was found in ' configpath '.  We will add one for you; modify it at will.']);

	copyfile([TwoPhotonPath filesep 'TwoPhotonUserInit--example.m'],[configpath filesep 'TwoPhotonUserInit.m']);
end;

mypwd = which('TwoPhotonUserInit');
if ~isempty(mypwd),
	TwoPhotonUserInit;
end;

addpath(TwoPhotonPath);
SetTwoPhotonConfiguration(TwoPhotonPlatform, TwoPhotonSynchronization);

d = dir([TwoPhotonPath filesep 'analyzetpstack' filesep 'analyzetpstack_draw_devices' filesep 'standard_draw_devices']);

for i=1:length(d),
	if ~d(i).isdir,
		k = findstr(d(i).name,'.m');
		if ~isempty(k),
			analyzetpstack_draw_devices('register',d(i).name(1:k-1));
		end;
	end;
end;


d = dir([TwoPhotonPath filesep 'analyzetpstack' filesep 'analyzetpstack_drift_devices' filesep 'standard_drift_devices']);

for i=1:length(d),
	if ~d(i).isdir,
		k = findstr(d(i).name,'.m');
		if ~isempty(k),
			analyzetpstack_drift_devices('register',d(i).name(1:k-1));
		end;
	end;
end;


