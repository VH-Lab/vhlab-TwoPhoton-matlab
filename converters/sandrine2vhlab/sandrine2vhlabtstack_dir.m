function sandrine2vhlabtstack_dir(dirname)
% SANDRINE2VHLABTSTACK_DIR - convert a whole directory of Sandrine experiments to vhlab t-stack format
%
% SANDRINE2VHLABTSTACK_DIR(DIRNAME)
%
% Coverts a whole directory of files in .lif format to vhlab t-stack format.
%

d = dir([dirname filesep '*.lif']);

for i=1:numel(d),
	datestring = ['20' d(i).name(1:2) '-' d(i).name(3:4) '-' d(i).name(5:6)];
	
	rest = d(i).name(7:end-4);

	dash = find(rest=='-');

	genotype = rest(1:dash(1)-1);

	parentdir = [dirname filesep genotype];
	conditiondir = [parentdir filesep rest(dash(1)+1:end)];
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

