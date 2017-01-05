function TwoPhotonInit

pwd = which('TwoPhotonInit');

pi = find(pwd==filesep); pwd = [pwd(1:pi(end)-1) filesep];

addpath([pwd filesep 'TPPreviewImageFunctionService']);
addpath([pwd filesep 'TPPreviewImageFunctions']);

addpath(genpath([pwd filesep 'analyzetpstack']));
addpath([pwd filesep 'kristen2vhlab']);
addpath([pwd filesep 'SynchronizationTests']);
addpath([pwd filesep 'export']);
addpath([pwd filesep 'sri']);
addpath([pwd filesep 'noise_analysis']);

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
	configpath= which('vhtools_configuration');
	[configpath,filename] = fileparts(configpath);

	disp(['No TwoPhotonUserInit file was found in ' configpath '.  We will add one for you; modify it at will.']);

	copyfile([pwd filesep 'TwoPhotonUserInit--example.m'],[configpath filesep 'TwoPhotonUserInit.m']);
end;

mypwd = which('TwoPhotonUserInit');
if ~isempty(mypwd),
	TwoPhotonUserInit;
end;

addpath(pwd);
SetTwoPhotonConfiguration(TwoPhotonPlatform, TwoPhotonSynchronization);

d = dir([pwd filesep 'analyzetpstack' filesep 'analyzetpstack_draw_devices' filesep 'standard_draw_devices']);

for i=1:length(d),
	if ~d(i).isdir,
		k = findstr(d(i).name,'.m');
		if ~isempty(k),
			analyzetpstack_draw_devices('register',d(i).name(1:k-1));
		end;
	end;
end;


d = dir([pwd filesep 'analyzetpstack' filesep 'analyzetpstack_drift_devices' filesep 'standard_drift_devices']);

for i=1:length(d),
	if ~d(i).isdir,
		k = findstr(d(i).name,'.m');
		if ~isempty(k),
			analyzetpstack_drift_devices('register',d(i).name(1:k-1));
		end;
	end;
end;


