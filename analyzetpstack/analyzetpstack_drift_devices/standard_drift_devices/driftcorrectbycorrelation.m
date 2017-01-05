function out=driftcorrectbycorrelation(parameters, input)

% DRIFTCORRECTBYCORRELATION - Perform drift correction by correlation
%
%   DRIFTCORRECTBYCORRELATION(PARAMETERS, INPUT)
%
%     PARAMETERS should be a structure with the following entries:
%         prompt_user (0/1)         Should we prompt the user every time to modify the parameters?
%         searchx                   The frame-by-frame search space in x, pixels (e.g., -10:2:10)
%         searchy                   The frame-by-frame search space in y, pixels (e.g., -10:2:10)
%         refsearchx                The search in x to perform to match the parent (e.g., -200:10:200)
%         refsearchy                The search in y to perform to match the parent (e.g., -200:10:200)
%         howoften                  How often we should do the search (e.g., 5 is every 5 frames)
%         avgframes                 The number of frames to average together (e.g., 5)
%         brightnesscorrect (0/1)   If 1, then images are normalized to their mean and standard deviation
%         roicorrect (0/1)          If 1, then every pixel less than the image mean is set to 0 to lesson
%                                       its impact
%         subtractmean (0/1)        If 1, then the mean is subtracted from the image before alignment
%         brightnessartifact (N)    If a number less than 100, then pixels below that percentile will be set to the mean
%         onlylocal (1)             Only correct within this directory (ignore any parent directory)
%         writeit (0/1)             Write the result to disk ('driftcorrect' in dirname)
%         plotit (0/1)              Should we plot the results graphically?
%         
%     INPUTS is the standard ANALYZETPSTACK_DRAW_DEVICE input structure with fields
%         dirname                   The dirname being examined
%         fullpathdirname           The full path of the directory being examined
%         refdirname                The parent directory (based on reference.txt file) of
%                                       the directory being examined
%         fullrefdirname            The full path of the parent directory
%         channel                   The channel number on which to perform drift correction
%         ds                        A directory structure object for traversing the
%                                       file structure for the entire experiment.

out = [];

if nargin==0,
	out = getdriftcorrectbycorrelationparameters([]);
	return;
end;

 % 1) extract parameters

struct2var(parameters);

if prompt_user,
	newparameters = getdriftcorrectbycorrelationparameters(parameters);
	if isempty(newparameters),
		return;
	end;
	struct2var(newparameters);
end;

if onlylocal,
	fullrefdirname = input.fullpathdirname;
	refdirname = input.dirname;
else,
	fullrefdirname = input.fullrefdirname;
	refdirname = input.refdirname;
end;

 % 2) perform drift correction

dr = tpdriftcheck(input.fullpathdirname, input.channel, searchx, searchy, ...
	fullrefdirname, refsearchx, refsearchy, ...
	howoften, avgframes, brightnesscorrect, ...
	roicorrect,subtractmean,brightnessartifact,writeit,plotit);

% that's it, we're done

 %%%%%%%%%%%%%%

function p = getdriftcorrectbycorrelationparameters(p)

if isempty(p),
    p = driftcorrectbycorrelation_defaultp;
end;
    
prompt = {'Prompt user to edit parameters each time? 0/1','Search space in x:','Search space in y:',...
		'Search space to match initial reference in x:','Search space to match initial reference in y:',...
		'Correct each N frames:','Average N frames together','Normalize images first?',...
		'Use brightest parts only?','Ignore pixels above X percentile (100=none)?',...
		'Only correct within this directory (I''ll manually align across directories)', ...
		'Write results (0/1) (should almost always be 1)', 'Plot results (0/1)'};
name = 'Parameters for drift correction function...';
numlines = 1;
defaultanswer = {
    mat2str(p.prompt_user), mat2str(p.searchx), mat2str(p.searchy),...
		mat2str(p.refsearchx), mat2str(p.refsearchy),...
		mat2str(p.howoften), mat2str(p.avgframes), mat2str(p.brightnesscorrect),...
		mat2str(p.roicorrect), mat2str(p.brightnessartifact),...
		mat2str(p.onlylocal),...
		mat2str(p.writeit), mat2str(p.plotit)};

answ = inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answ), return; end;

prompt_user = eval(answ{1}); searchx = eval(answ{2}); searchy = eval(answ{3});
refsearchx = eval(answ{4}); refsearchy = eval(answ{5});
howoften = eval(answ{6}); avgframes = eval(answ{7}); brightnesscorrect = eval(answ{8});
roicorrect = eval(answ{9}); brightnessartifact = eval(answ{10});
onlylocal = eval(answ{11});
writeit = eval(answ{12}); plotit = eval(answ{13});

subtractmean = 0;

p = workspace2struct;
p = rmfield(p,{'prompt','name','p','numlines','defaultanswer','answ'}); 

