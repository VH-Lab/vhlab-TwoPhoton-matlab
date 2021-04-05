function [rgr, out] = tp_sydney_red_green_ratio(dirname)
% TP_SYDNEY_RED_GREEN - compute red/green ratio for Sydney Padgett's data
%
% OUT = TP_SYDNEY_RED_GREEN_RATIO(DIRNAME)
%
% Given an experiment directory, return the RED/GREEN ratio from a set of cells that are
% defined in t00001 (green) and exist in t00002 (red).
%
% The red/green ratio will be defined as RED_SIGNAL/(RED_SIGNAL+GREEN_SIGNAL)
%
% Example:
%  [rgr,out] = tp_sydney_red_green_ratio(['/Users/sydney/VHMatlab/2021-04-32']);
%  rgr,
% 

rgr = [];

ds = dirstruct(dirname);

s = getscratchdirectory(ds);

stacks = dir([s filesep '*.stack']);

if isempty(stacks),
	error(['No stacks found in ' s '.']);
elseif numel(stacks)>1,
	error(['Too many stacks found in ' s '.']);
end;

out.stack = load([s filesep stacks(1).name],'-mat');

channel = 1;

[out.green_data,t] = tpreaddata([dirname filesep 't00001'],[-1 2],{out.stack.celllist.pixelinds},1,channel);
[out.red_data,t] =   tpreaddata([dirname filesep 't00002'],[-1 2],{out.stack.celllist.pixelinds},1,channel);

for i=1:numel(out.green_data),
	rgr(i) = out.red_data{i}/(out.red_data{i}+out.green_data{i});
end;

