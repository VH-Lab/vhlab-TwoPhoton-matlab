function SetTwoPhotonConfiguration(platform, synchronization)
% SETTWOPHOTONCONFIGURATION - Sets configuration for TWOPHOTON analysis
%
%  SETTWOPHOTONCONFIGURATION(PLATFORM, SYNCHRONIZATION)
%
%  Sets the 2-photon configuration, so the system knows what
%  microscope and synchronization method the user is using.
%
%  Valid platforms are listed in the TWOPHOTON/Platforms
%  directory, and valid synchronization methods are listed
%  in the TWOPHOTON/SYNCHRONIZATION directory.
%
%

pwd = which('TwoPhotonInit');

pi = find(pwd==filesep); pwd = [pwd(1:pi(end)-1) filesep];

d1 = dir([pwd 'Platforms' filesep '*']);
d2 = dir([pwd 'Synchronization' filesep '*']);

warn = warning;

warning off;

for i=1:length(d1),
    if d1(i).isdir,
        rmpath([pwd 'Platforms' filesep d1(i).name]);
    end;
end;

for i=1:length(d2),
    if d2(i).isdir,
        rmpath([pwd 'Synchronization' filesep d2(i).name]);
    end;
end;

warning(warn);

global TwoPhotonPlatform TwoPhotonSynchronization

TwoPhotonPlatform = platform;
TwoPhotonSynchronization = synchronization;

addpath([pwd 'Platforms' filesep TwoPhotonPlatform]);
addpath([pwd 'Synchronization' filesep TwoPhotonSynchronization]);
