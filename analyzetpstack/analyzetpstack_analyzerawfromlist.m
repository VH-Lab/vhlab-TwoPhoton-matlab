function analyzetpstack_analyzerawfromlist(prefix, experlist, stacknamelist, channellist)
% ANALYZETPSTACK_ANALYZERAWFROMLIST - Analyze raw F from a list of analyzetpstack stacks
%
%   ANALYZETPSTACK_ANALYZERAWFROMLIST(PREFIX, EXPERLIST, STACKNAMELIST, CHANNELLIST)
%
%   Analyzes a set of experiments.  First, the program will loop through and verify it can
%   open all of the experiments; then it will proceed to call ANALYZETPSTACK_ANALYZERAWFROMLIST.
%   The filenames are presumed to be [PREFIX filesep EXPERLIST{i}], the stack names are assumed to
%   be STACKNAMELIST{i}, and the channel numbers to read from are in CHANNELLIST(i)
%
%   Example:  
%     prefix  = 'C:\Users\myname'
%     experlist = {'2013-05-05','2013-05-06'}
%     stacknamelist = {'Stack 1.stack','Stack 1.stack'}
%     channellist = [ 1 1]
%     analyzetpstack_analyzerawfromlist(prefix,experlist,stacknamelist,channellist)
%
%
%  See also:  ANALYZETPSTACK, ANALYZETPSTACK_ANALYZERAWALL

 % Step 1 - first loop through and make sure we can load all the files

for i=1:length(experlist),
	disp(['Testing ' experlist{i} ' with stackname ' stacknamelist{i} ' and channel number ' int2str(channellist(i)) '.']);
	ds = dirstruct([prefix filesep experlist{i}]);
	z = load([getpathname(ds) filesep 'analysis' filesep 'scratch' filesep stacknamelist{i}],'-mat');
end;

  % Step 2 - do the analysis!

for i=1:length(experlist),
	disp(['Analyzing ' experlist{i} ' with stackname ' stacknamelist{i} ' and channel number ' int2str(channellist(i)) '...']);
	ds = dirstruct([prefix filesep experlist{i}]);
	analyzetpstack_analyzerawall([],channellist(i),ds,stacknamelist{i});
end;
