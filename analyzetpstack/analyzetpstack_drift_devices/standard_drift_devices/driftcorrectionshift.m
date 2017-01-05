function out=driftcorrectionshift(parameters, input)

% DRIFTCORRECTIONSHIFT - Perform a manual drift shift on existing drift correct shift
%
%   DRIFTCORRECTBYCORRELATION(PARAMETERS, INPUT)
%
%     PARAMETERS should be a structure with the following entries:
%         warning_msg (0/1)         Should we print the warning message?
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
	prompt = {'Display the warning message each time? (0/1)'};
	name = 'Parameters for manual drift shift...';
	numlines = 1;
	defaultanswer = {'1'};
	answ = inputdlg(prompt,name,numlines,defaultanswer);
	if isempty(answ), return; end;
	out.warning_msg = eval(answ{1});
	return;
end;

if parameters.warning_msg,
	warndlg('Warning: you should use CheckDrift on a bright cell to check the results of your manual shifts over the duration of the recording.  Even if the shift is good at the beginning of the trial, it may slip later on.  It is recommended that you first try adjusting the drift correct parameters and correcting drift again before resorting to manually shifting.','Warning');
end;

 % 1) ask user for shift parameters

prompt = {'Shift in x:','Shift in y:'};
name = 'Parameters for manual drift shift...';
numlines = 1;
defaultanswer = {'0','0'};
answ = inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answ), return; end;

 % 2) perform drift correction
tpdirs = tpdirnames(input.fullpathdirname);

for i=1:length(tpdirs),
	shiftdriftcorrect(tpdirs{i},eval(answ{1}),eval(answ{2})); 
end;

% that's it, we're done

