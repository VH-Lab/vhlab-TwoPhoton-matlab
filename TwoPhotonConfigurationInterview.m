function TwoPhotonConfigurationInterview

config_string = {'function TwoPhotonConfiguration' '' 'TwoPhotonGlobals;' '' };

fname = which('vhtools_configuration');

[path,filename] = fileparts(fname);

twophotonconfigname = [path filesep 'TwoPhotonConfiguration.m'];

if exist(twophotonconfigname),
	movefile(twophotonconfigname,[path filesep 'TwoPhotonConfiguration_bkup.m']);
end;

tpdir = fileparts(which('TwoPhotonInit.m'));

tpplat = dir([tpdir filesep 'Platforms']);
indstoinclude = [];
for i=1:length(tpplat),
	if tpplat(i).isdir & ~(strcmp(tpplat(i).name,'.')|strcmp(tpplat(i).name,'..')),
		indstoinclude(end+1) = i;
	end;
end;
tpplat = tpplat(indstoinclude);


tpsync = dir([tpdir filesep 'Synchronization']);
indstoinclude = [];
for i=1:length(tpsync),
	if tpsync(i).isdir & ~(strcmp(tpsync(i).name,'.')|strcmp(tpsync(i).name,'..')),
		indstoinclude(end+1) = i;
	end;
end;
tpsync = tpsync(indstoinclude);

TwoPhotonPlatform_options = {tpplat.name};
TwoPhotonSynchronization_options = {tpsync.name};

v = 0;

while v==0,
	[s,v] = listdlg('PromptString','TwoPhoton Configuration: Select your microscope platform:',...
                      'SelectionMode','single',...
                      'ListString',TwoPhotonPlatform_options,'ListSize',[400 300]);
end;

config_string = cat(2,config_string, {['TwoPhotonPlatform = ''' TwoPhotonPlatform_options{s} ''';']});

v = 0;
while v==0,
	[s,v] = listdlg('PromptString','TwoPhoton Configuration: Select your synchronization method:',...
                      'SelectionMode','single',...
                      'ListString',TwoPhotonSynchronization_options,'ListSize',[400 300]);
end;

config_string = cat(2,config_string, {['TwoPhotonSynchronization = ''' TwoPhotonSynchronization_options{s} ''';']});

TwoPhotonGlobals;
if isempty(tpstacktypes),
	tpstacktypes = {'cell','glia','dend'};
end;
if isempty(tpstacklabels),
	tpstacklabels = {'Oregon green','Sulforodamine 101','Rhodamine','FURA','GFP','tdTomato'};
end;


answer = {};
while isempty(answer),
	prompt={'Two Photon Configuration: Object types:','Labels for markers:'};
	name='TwoPhoton stack drawing types and labels';
	numlines=1;
	defaultanswer={cell2str(tpstacktypes),cell2str(tpstacklabels)};
	options.Resize='on';
	answer=inputdlg(prompt,name,numlines,defaultanswer,options);
	try,
		my1 = eval(answer{1});
		my2 = eval(answer{2});
		tpstacktypes = my1;
		tpstacklabels = my2;
	catch,
		answer = {};
	end;
end;

config_string = cat(2, config_string, {'' ['tpstacktypes = ' cell2str(tpstacktypes) ';'] });
config_string = cat(2, config_string, {['tpstacklabels = ' cell2str(tpstacklabels) ';'] ''});

config_string = cat(2, config_string, { ... 
	'TPPreviewImageFunctionListGlobals;' '' ...
	'TPPreviewImageFunctionChannelList = 1:4;' '' ...
	'TPPreviewImageFunctionListClear;' ...
	'TPPreviewImageFunctionListAdd(''tppreview_frameaverage'',''default'',struct(''firstFrames'',1,''numFrames'',30));' ...
	'TPPreviewImageFunctionListAdd(''tppreview_timethreshaverage'',''gCamp_v1'',struct(''numFrames'',200,''smoothing'',5,''diffThresh'',500));' ...
});


tp_parameters=inputdlg({'Warn me if drift exceeds (pixels):'},'TwoPhoton parameters:',1,{'50'});
config_string = cat(2, config_string, {['TwoPhotonDriftWarn = ' tp_parameters{1} ';']});

	% open a text file for writing
fid = fopen(twophotonconfigname,'wt');

if fid>0,
	for i=1:length(config_string),
		fprintf(fid,'%s\n',config_string{i});
	end;
	fclose(fid);
end;

