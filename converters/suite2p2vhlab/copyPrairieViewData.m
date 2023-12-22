function copyPrairieViewData(oldtarget, newtarget, ignoredriftcorrect, doit)

if nargin<3,
	ignoredriftcorrect = 0;
end;
if nargin<4,
	doit = 0;
end;

d = dir([oldtarget filesep '*']);

for i=1:numel(d),
	if ~d(i).isdir,
		if ~strcmp(d(i).name,'driftcorrect') | ~ignoredriftcorrect,
			fname_source = fullfile(oldtarget,d(i).name);
			fname_target = fullfile(newtarget,d(i).name);
			if ~doit,
				disp(['copyfile ' ...
					fname_source ' TO ' fname_target '.']);
			else,
				copyfile(fname_source,fname_target);
			end;
		end;
	end;
end;


