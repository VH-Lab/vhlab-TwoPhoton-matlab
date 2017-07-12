function [mti2,starttime] = tpcorrectmti(mti, filename,globaltime)

% TPCORRECTMTI - Correct NewStim MTI based on recorded times
%
% [MTI2,STARTTIME] = TPCORRECTMTI(MTI, STIMTIMEFILE,[GLOBALTIME])
%
%   Returns a time-corrected MTI timing file given actual timings
% recorded by the Spike2 machine and saved in a file named 
% STIMTIMEFILE.
%
% GLOBALTIME is an optional argument.  If it is 1 then time is returned
% relative to the stimulus computer's clock.
%
% This function will save its work to a file called 'tpcorrectmti_fitzpatrick.mat'
% and just read from this file if the modification date of 'filename' hasn't changed
% since it last checked.
%
% This function just calls vhlabcorrectmti.
% 
% From FITZCORRECTMTI by Steve Van Hooser
%

[mti2,starttime]=vhlabcorrectmti(mti,filename,globaltime);

