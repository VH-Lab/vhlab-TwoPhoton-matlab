function [im,fname]=tpreadframe(dirname,tpfileparams,cycle,channel,frame)
%TPREADFRAME
%  read frame from multitiff
%
% 2008, Alexander Heimel
%

fname=[dirname filesep tpfileparams.fnameprefix '_t' sprintf('%.4d',frame-1) tpfileparams.extension];
im=sum(imread(fname),3);
