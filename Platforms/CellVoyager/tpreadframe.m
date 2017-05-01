function [im,fname]=tpreadframe(dirname,tpfileparams,cycle,channel,frame)
%TPREADFRAME
%  read frame from single tiff
%
% 2008, Alexander Heimel
%
fname=fullfile(dirname,tpfilename(tpfileparams,cycle,channel,frame));
im=imread(fname,frame);
if length(size(im)>2),
    im = mean(double(im),3);
end;

