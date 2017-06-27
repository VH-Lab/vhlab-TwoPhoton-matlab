function [im,fname]=tpreadframe(dirname,fnameprefix,cycle,channel,frame)
%TPREADFRAME
%  read frame from multitiff
%
% 2008, Alexander Heimel
% 2017, Steve Van Hooser
%
fname=fullfile(dirname,tpfilename(fnameprefix,cycle,channel,frame));

cycle_string = ['Cycle_' int2str(cycle)];

fname,
getfield(getfield(fnameprefix,cycle_string),'imfinfo')

im=imread(fname,frame,'info',getfield(getfield(fnameprefix,cycle_string),'imfinfo'));
