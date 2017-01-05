function TPPreviewImageFunctionListClear

% TPPREVIEWIMAGEFUNCTIONLISTCLEAR - Clear the PI function list
%
%   TPPREVIEWIMAGEFUNCTIONLISTCLEAR
%
%  This function removes all PreviewImage functions

TPPreviewImageFunctionListGlobals;

TPPreviewImageFunctionList = TPPreviewImageFunctionList([]);
