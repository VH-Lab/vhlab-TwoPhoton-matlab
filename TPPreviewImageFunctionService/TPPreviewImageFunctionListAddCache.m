function TPPreviewImageFunctionListAddCache(filename, pvimg, params, parameters, dirname, tpfnameparameters, total_frames, dirnames)
% TPPREVIEWIMAGEFUNCTIONLISTADDCACHE - Add preview image parameters to the cache
%
%  TPPREVIEWIMAGEFUNCTIONLISTADDCACHE(FILENAME, PREVIEWIMAGE, PARAMS, PARAMETERS, ...
%           DIRNAME, TPFNAMEPARAMETERS, TOTAL_FRAMES, DIRNAMES)
%
%  Adds the TPPreviewImageFunctionList data to the TPPreviewImageCache global variable
%  If another cache entry already contains the filename, then the information is overrwritten and 
%  the entry is moved to the 'top' of the cache. If necessary, any entries that exceed the number
%  allowed in the global variable TPPreviewImageCacheMax are deleted.
%
%  If TPPreviewImageCacheMax is empty, then a default value of 5 is assumed.
%

mystruct = workspace2struct;

TPPreviewImageFunctionListGlobals;

if isempty(TPPreviewImageCacheMax),
	TPPreviewImageCacheMax = 5;
end;

if isempty(TPPreviewImageCache),
	match = [];
else,
	match = find(strcmp(filename,{TPPreviewImageCache.filename}));
end;

if ~isempty(match),
	TPPreviewImageCache(match) = mystruct;
	TPPreviewImageCache = TPPreviewImageCache([match 1:match-1 match+1:end]); % move to 'top'
else,
	TPPreviewImageCache = [mystruct; TPPreviewImageCache]; % add to 'top'
	n = numel(TPPreviewImageCache);
	TPPreviewImageCache = TPPreviewImageCache(1:min(n,TPPreviewImageCacheMax)); % drop any that exceed cache memory
end;	



