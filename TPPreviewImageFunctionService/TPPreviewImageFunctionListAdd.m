function b = TPPreviewImageFunctionListAdd(functionName, shortname, parameters)

% TPPREVIEWIMAGEFUNCTIONLISTADD - Add a 2-photon preview image function to the list
%
%  B = TPPREVIEWIMAGEFUNCTIONLISTADD(FUNCTIONNAME, SHORTNAME, PARAMETERS)
%
%    Adds the function FUNCTIONNAME to the list of 2-photon preview image functions.
%    PARAMETERS is the parameters that should be passed to the function.  SHORTNAME is
%    a unique string that describes how this particular combination of FUNCTIONNAME and
%    PARAMETERS should be referenced in the menu bar and in saved files on disk.
%    SHORTNAME should only contain characters that are valid within a file name on all 
%    platforms.
%
%    The functions to be added should accept the following arguments:
%
%        [ims,channels] = PREVIEWIMAGEFUNC(DIRNAMES, TPPARAMS, CHANNELLIST,
%            PARAMETERS)
%
%      where DIRNAMES is the list of directories where the 2-photon data resides, TPPARAMS is a cell
%    list of parameter values associated with the 2-photon directories, CHANNELLIST is a list of 
%    channels to try to analyze, and PARAMETERS is the structure that you passed to 
%    TPPREVIEWIMAGEFUNCTIONLISTADD above.  This function type should return ims, a cell list of
%    preview images for each channel that was found, which is returned in channels.  shortname is the
%    name that should be inserted in the preview image file on disk, for example 'frameaverage' is the
%    shortname for the function TPPREVIEW_FRAMEAVERAGE (a good example to read if you want to write
%    your own preview image function).  
%
%    See also:  TPPreviewImageFunctionListGet TPPreviewImageFunctionListCompute

TPPreviewImageFunctionListGlobals;

myDevStruct = struct('FunctionName',functionName, 'shortname', shortname, 'parameters', parameters);

if isempty(TPPreviewImageFunctionList),
	TPPreviewImageFunctionList = myDevStruct;
else,
	TPPreviewImageFunctionList(end+1) = myDevStruct;
end;


