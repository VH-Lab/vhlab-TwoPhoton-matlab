function params=tpreadconfig( tpdirname )
%TPREADCONFIG read twophoton experiment config file
%
%
% PARAMS. = 
%  params.Main.Total_cycles  (total number of cycles)
%  params.Main.Scanline_period__us_  (scanline period, in us)
%  params.Main.Dwell_time__us_  (pixel dwell time, in us)
%  params.Main.Frame_period__us_  (frame period, in us)
%  params.Main.Lines_per_frame (lines per frame)
%  params.Main.Pixels_per_line  (number of pixels per line)
%  params.Image_TimeStamp__us_  (list of all frame timestamps)
%  params.Cycle_N.Number_of_images (num. of images in Cycle N)
%
%   params.Image_TimeStamp__s_   = params.Image_TimeStamp__us_ * 1E-6
%
% FluoView version
%
% 2008, Alexander Heimel
%

% TEMPORARY
if nargin<1
  switch host
    case 'eto'
      tpdirname='/home/data/InVivo/Twophoton/test/2008-06-09/t00001';
    otherwise
      tpdirname='/mnt/nas002/InVivo/Twophoton/test/2008-06-09/t00001';
  end
end

fname=fullfile(tpdirname,tpfilename);
inf=fluoview_tiffinfo(fname);
inf(1)


params.Main.Lines_per_frame = inf(1).Height;
params.Main.Pixels_per_line = inf(1).Width;
params.Main.Total_cycles = 1;
params.Cycle_1.Number_of_images=length(inf);

params.Main.Scanline_period__s_ = inf(1).SecondsPerScanLine; % scanline period in s
params.Main.Scanline_period__us_= params.Main.Scanline_period__s_ *1e6; %scanline period in us

params.Main.Dwell_time__s_ = params.Main.Scanline_period__s_ / params.Main.Pixels_per_line; % pixel dwell time in us
params.Main.Dwell_time__us_ =  params.Main.Dwell_time__s_*1e6;


warning('params.Main.Frame_period__s_ is inaccurate.');
params.Main.Frame_period__s_ = params.Main.Lines_per_frame * params.Main.Scanline_period__s_; % frame period in s
params.Main.Frame_period__us_ = params.Main.Frame_period__s_ * 1e6; % frame period in us

warning('params.Image_TimeStamp__s_ is inaccurate.');
params.Image_TimeStamp__s_ = (0:length(inf)-1)*params.Main.Frame_period__s_; % list of all frame timestamps in s
params.Image_TimeStamp__us_   = params.Image_TimeStamp__s_ * 1E6; % list of all frame timestamps in s


