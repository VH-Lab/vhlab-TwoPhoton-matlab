function p = driftcorrectbycorrelation_defaultp 
% DRIFTCORRECTBYCORRELATION_DEFAULTP - Return defaults parameters for DRIFTCORRECTBYCORRELATION method
%
%  P = DRIFTCORRECTBYCORRELATION_DEFAULTP(...)
%
%  Returns default parameters for the DRIFTCORRECTIONBYCORRELATION method
%
%  The user can override these values by passing name/value pairs (e.g., adding
%  'prompt_user', 0, as input arguments will override the default value of 1 for
%  parameter 'prompt_user':
%
%  Parameter name (default)         | Description
%  ----------------------------------------------------------------------------------------------
%  prompt_user (1)                  | Should we prompt the user every time to modify the parameters?
%  searchx (-6:2:6)                 | The frame-by-frame search space in x, pixels (e.g., -10:2:10)
%  searchy (-6:2:6)                 | The frame-by-frame search space in y, pixels (e.g., -10:2:10)
%  refsearchx (-100:10:100)         | The search in x to perform to match the parent (e.g., -200:10:200)
%  refsearchy (-100:10:100)         | The search in y to perform to match the parent (e.g., -200:10:200)
%  howften (10)                     | How often we should do the search (e.g., 5 is every 5 frames)
%  avgframes (5)                    | The number of frames to average together (e.g., 5)
%  brightnesscorrect (1)            | If 1, then images are normalized to their mean and standard deviation
%  roicorrect (1)                   | If 1, then every pixel less than the image mean is set to 0 to lesson
%                                   |    its impact
%  subtractmean (0)                 | If 1, then the mean is subtracted from the image before alignment
%  brightnessartifact (100)         | If a number less than 100, then pixels below that percentile
%                                   |    will be set to the mean
%  onlylocal (0)                    | Only correct within this directory (ignore any parent directory)
%  writeit (1)                      | Write the result to disk ('driftcorrect' in dirname)
%  plotit (1)                       | Should we plot the results graphically?


prompt_user = 1;
searchx = -6:2:6;
searchy = -6:2:6;
refsearchx = -100:10:100;
refsearchy = -100:10:100;
howoften = 10;
avgframes = 5;
brightnesscorrect = 1;
roicorrect = 1;
subtractmean = 0;
brightnessartifact = 100;
onlylocal = 0;
writeit = 1;
plotit = 1;

p = workspace2struct;

