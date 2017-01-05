function previews2tif(dirname)

% PREVIEWS2TIF - Convert all preview images in a 2P directory to TIF
%
%  PREVIEWS2TIF(DIRNAME)
%
%  The files will be written in the DIRNAME/analysis/scratch directory.
%
%  All files will be scaled by their minimum and maximal pixel values.
%

ds = dirstruct(dirname);

sd = getscratchdirectory(ds);

if ~isempty(sd),
	d = dir([sd filesep 'preview*.mat']);
	for i=1:length(d),
		if ~eqlen(d(i).name,'..')&~eqlen(d(i).name,'.'),
			g = load([sd filesep d(i).name]);
			[pathname,filename] = fileparts(d(i).name);
			g.pvimg = double(g.pvimg);
			img = rescale(g.pvimg,[min(g.pvimg(:)) max(g.pvimg(:))],[0 255]);
			imwrite(uint8(img),[sd filesep d(i).name '.tiff'],'tiff');
		end;
	end;
end;


