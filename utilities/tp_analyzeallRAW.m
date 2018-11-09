function tp_analyzeallRAW(prefix, depth)
% TP_ANALYZEALLRAW - Traverse all tp 'stack' folders for a given experiment, click analyze raw, and add to database
%
% TP_ANALYZEALLRAW(PREFIX, [DEPTH])
%
% Given a data directory in PREFIX, explore all subdirectories to identify which are 
% VH Lab experiment directories (with 't00' subfolders inside). Then, when an experiment
% has been identified, all saved stacks from ANALYZETPSTACK are opened, cells are processed with 
% 'Analyze all raw', and cells are added to the database with 'Add to Database'. Then, all windows
% are closed. This processes is repeated for all identified experiment directories on the path.
%
% DEPTH indicates how many subdirectories are examined recursively. If not provided,
% DEPTH is 2.
% 

 % looks for directories that have t-folders
 
if nargin<2, depth = 2; end;
 
dirlist = dirlist_trimdots(dir(prefix),0);
 
for i=1:numel(dirlist),
	% dirlist{i},
	if strncmp(lower(dirlist{i}),'t00',3)
		% then prefix is an experiment, so run it
		ds = dirstruct(prefix);
		stack_files = dir([getscratchdirectory(ds) filesep '*.stack']);
		for j=1:numel(stack_files),
			disp(['Now running raw trace calculation on ' prefix '...']);
			[thepath,stackname,ext] = fileparts(stack_files(j).name);
			analyzetpstack(prefix,stackname);
			analyzetpstack('loadBt',stackname,gcf);
			drawnow
			analyzetpstack_slicelist('AnalyzeAllRawAddToDatabaseBt',stackname,gcf);
			close(gcf);
			close all
		end
		return
	else, % then it is a subdirectory, pursue it
		if depth>0,
			tp_analyzeallRAW(fullfile(prefix,dirlist{i}), depth-1);
		end
	end
end
 
 
