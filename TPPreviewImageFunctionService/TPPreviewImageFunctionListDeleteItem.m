function TPPreviewImageFunctionListDeleteItem(i)

% TPPREVIEWIMAGEFUNCTIONLISTDELETEITEM - Delete a function from PI function list
%
%   TPPREVIEWIMAGEFUNCTIONLISTDELTEITEM(ITEMINDEXES)
%
%  This function removes all PreviewImage functions with index values in
%  ITEMINDEXES.  For example, pass [1 2] to remove the first and second items.
%  To read the items, use TPPREVIEWIMAGEFUNCTIONLISTGET

TPPreviewImageFunctionListGlobals;

TPPreviewImageFunctionList = TPPreviewImageFunctionList(setdiff(1:length(TPPreviewImageFunctionList),i));
