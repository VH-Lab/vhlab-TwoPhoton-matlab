function out=driftcorrectionmanual(parameters, input)

% DRIFTCORRECTIONSHIFT - Perform a manual drift manual on existing drift correct manual
%
%   DRIFTCORRECTBYCORRELATION(PARAMETERS, INPUT)
%
%     PARAMETERS should be a structure with the following entries:
%         instruction_msg (0/1)         Should we print the instruction message?
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
%         view                      The TPPreview function shortname to be used for the images
%         viewchannel               The channel currently being viewed in the analyzetpstack preview window
%         viewframe                 The frame number currently being viewed in the analyzetpstack preview window
%         viewColorMinMax           The color Min and Max value currently being viewed in the analyzetpstack preview window
%         xyoffset                  A 1x2 matrix with the manual x/y offset for this directory
%         refxyoffset               A 1x2 matrix with the manual x/y offset of the reference directory
%         analyzetpstack_handle     Window handle of current analyzetpstack window

out = [];

if nargin==0,
	prompt = {'Display the instruction message each time? (0/1)'};
	name = 'Parameters for manual drift manual...';
	numlines = 1;
	defaultanswer = {'0'};
	answ = inputdlg(prompt,name,numlines,defaultanswer);
	if isempty(answ), return; end;
	out.instruction_msg = eval(answ{1});
	return;
end;

if parameters.instruction_msg,
	msgbox('You will now be shown a window for manual drift correction. Please see the Help button for documentation.','Instructions');
end;

driftcorrection_graphical('inputs',input);

% that's it, we're done

