function previews2tif(ds, dirname,scale,map)

% PREVIEWS2TIF - Convert all preview images in a 2P directory to TIF
%
%  PREVIEWS2TIF(DS, DIRNAME [, SCALE, MAP])
%
%  DS is a directory structure DIRSTRUCT object.
%
%  The files will be written in the DIRNAME/analysis/scratch directory.
%
%  All files will be scaled by their minimum and maximal pixel values
%  unless SCALE is given; then images will be scaled between SCALE(1)
%  and SCALE(2).
%  
%  If no MAP is given, then the gray color map of 256 entries is used. Otherwise,
%  MAP is used. 
%

if nargin<3,
    scale = [];
end;

if nargin<4,
    map = gray(256);
end;

sd = getscratchdirectory(ds);

dirname_fullpath = [getpathname(ds) filesep dirname filesep];

if ~isempty(sd),
	d = dir([dirname_fullpath 'tppreview*.mat']);
	for i=1:length(d),
        g = load([dirname_fullpath filesep d(i).name]);
        [pathname,filename] = fileparts(d(i).name);
        g.pvimg = double(g.pvimg);
        if isempty(scale),
            scale_here = [min(g.pvimg(:)) max(g.pvimg(:))];
        else,
            scale_here = scale;
        end;
        img = rescale(g.pvimg,scale_here,[0 size(map,1)-1]);
        if size(map,1)>2^16,
            img_ = uint32(img);
        elseif size(map,1)>2^8,
            img_ = uint16(img);
        else,
            img_ = uint8(img);
        end;
        imwrite(img_,map,[sd filesep dirname '_' d(i).name '.tif']);
	end;
end;
