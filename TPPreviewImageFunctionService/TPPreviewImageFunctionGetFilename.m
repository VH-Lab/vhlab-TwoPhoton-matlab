function [static_filename, video_filename] = TPPreviewImageFunctionGetFilename(dirname, shortname, channel, frame)
% TPPREVIEWIMAGEFUNCTIONGETFILENAME - return the static image and video image file names
%
% [STATIC_FILENAME, VIDEO_FILENAME] = TPPREVIEWIMAGEFUNCTIONGETFILENAME(...
%     DIRNAME, SHORTNAME, CHANNEL, FRAME)
%
% Return the standard filename of the static preview images (STATIC_FILENAME)
% and video filename (VIDEO_FILENAME) given a directory name DIRNAME, 
% the preview function's SHORTNAME, the CHANNEL, and a FRAME number.
%

static_filename = [dirname filesep 'tppreview_' shortname ...
	'_ch' int2str(channel) '.mat'];

video_filename = [dirname filesep 'tppreviewvideo_' shortname ...
	'_ch' int2str(channel) '.tiff'];


