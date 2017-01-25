% TPPREVIEWIMAGEFUNCTIONLISTGLOBALS - Declare global variables for TPPreviewImage functions
%
%   Declares the global variable 
%
%      TPPreviewImageFunctionList  -- a structure list of installed TPPreviewImage functions
%      TPPreviewImageFunctionChannelList - a list of installed acquisition channels, such 
%                                          as [1 2 3 4]
%
%      TPPreviewImageCache    -- a structure list of cached preview images. This is the information
%                                normally stored in the .mat file for the preview image
%          Fieldnames                  | Description
%          ------------------------------------------------------------
%          filename                    | The full path filename of the preview image
%          params                      | The two-photon parameters for this directory
%          dirnames                    | The two-photon directory names where the data is stored
%          tpfnameparameters           | The twp-photon file name parameters 
%          total_frames                | The total number of frames
%          
%      TPPreviewImageCacheMax -- the maximum number of preview images to cache
%      

global TPPreviewImageFunctionList
global TPPreviewImageFunctionChannelList

global TPPreviewImageCache
global TPPreviewImageCacheMax 
 
