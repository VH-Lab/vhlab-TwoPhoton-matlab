function sandrine2vhlabtstack_dir(dirname)
% SANDRINE2VHLABTSTACK_DIR - convert a whole directory of Sandrine experiments to vhlab t-stack format
%
% SANDRINE2VHLABTSTACK_DIR(DIRNAME)
%
% Coverts a whole directory of files in .lif format to vhlab t-stack format.
%

d = dir([dirname filesep '*.lif']);

if isempty(d),
	error(['Found no *.lif files in directory ' dirname '.']);
end;

for i=1:numel(d),
	if strncmp(d(i).name,'20',2),
		% it has the 20 out front
		datestring = [d(i).name(1:4) '-' d(i).name(5:6) '-' d(i).name(7:8)];
		rest = d(i).name(9:end-4);
	else, % it doesn't
		datestring = ['20' d(i).name(1:2) '-' d(i).name(3:4) '-' d(i).name(5:6)];
		rest = d(i).name(7:end-4);
	end;

	dash = find(rest=='-');

	if isempty(dash),
		genotype = 'GT';
	else,
		genotype = rest(1:dash(1)-1);
	end;

	if isempty(dash),
		condition_string = rest;
	else,
		condition_string = rest(dash(1)+1:end);
	end;

	parentdir = [dirname filesep genotype];
	conditiondir = [parentdir filesep condition_string];
	fulldir = [conditiondir filesep datestring];

	try,
		mkdir([parentdir]);
	end
	try,
		mkdir([conditiondir]);
	end
	try,
		mkdir([fulldir]);
	end

	sandrine2vhlabtstack([dirname filesep d(i).name], [fulldir]);
end

