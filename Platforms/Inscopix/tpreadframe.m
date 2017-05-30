function [im,fname]=tpreadframe(dirname,fnameprefix,cycle,channel,frame)
%TPREADFRAME
%  read frame from multitiff
%
% 2008, Alexander Heimel
%
fname=fullfile(dirname,tpfilename(fnameprefix,cycle,channel,frame));

cycle_string = ['Cycle_' int2str(cycle)];

im=imread(fname,frame,'info',getfield(getfield(fnameprefix,cycle_string),'imfinfo'));
