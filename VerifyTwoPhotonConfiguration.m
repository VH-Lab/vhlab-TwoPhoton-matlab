function b = VerifyTwoPhotonConfiguration

b = 1;

TwoPhotonGlobals;

if isempty(TwoPhotonPlatform)|isempty(TwoPhotonSynchronization)|isempty(tpstacklabels)|isempty(tpstacktypes), b = 0; end;

TPPreviewImageFunctionListGlobals;

if isempty(TPPreviewImageFunctionChannelList), b = 0; end;

