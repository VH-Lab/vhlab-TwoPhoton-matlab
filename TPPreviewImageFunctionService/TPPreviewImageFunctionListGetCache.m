function out=TPPreviewImageFunctionListGetCache(filename)
% TPPREVIEWIMAGEFUNCTIONLISTGETCACHE - Get preview image parameters to the cache
%
%  OUT=TPPREVIEWIMAGEFUNCTIONLISTGETCACHE(FILENAME)
%
%  Gets the TPPreviewImageFunctionList data from the TPPreviewImageCache global variable for the
%  filename FILENAME. If that information is not in the cache, then it is read from disk.
%

TPPreviewImageFunctionListGlobals;

if isempty(TPPreviewImageCache),
	match = [];
else,
	match = find(strcmp(filename, {TPPreviewImageCache.filename}));
end;

if ~isempty(match),
	out = TPPreviewImageCache(match);
else,
	vars = load(filename);
	possiblyemptyfieldnames = {'tpfnameparameters','total_frames','dirnames'};
	for i=1:length(possiblyemptyfieldnames),
		if ~isfield(vars,possiblyemptyfieldnames{i}),
			vars = setfield(vars,possiblyemptyfieldnames{i},[]);
		end;
	end;
	TPPreviewImageFunctionListAddCache(filename,vars.pvimg, vars.params, vars.parameters, vars.dirname, vars.tpfnameparameters, vars.total_frames, vars.dirnames);
	out = TPPreviewImageFunctionListGetCache(filename); % make sure we get the structure in the right order, vars might differ from out; 
end;	


