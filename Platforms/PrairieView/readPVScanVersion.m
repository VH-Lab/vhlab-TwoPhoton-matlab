function [version, version_string] = readPVScanVersion(fid)
% readPVScanVersion - Read the version of the PrairieView scanning program from a file
%
%   [VERSION,VERSION_STRING] = READPVSCANVERSION(FID)
%
%   Given a file ID number FID of a PairieView/PrairieScan XML file,
%   this function reads the file and looks for the version string
%   (e.g., '5.0.32.100'). The VERSION is decoded (e.g., [5 0 32 100]) and
%   returned along with the VERSION_STRING.
%
%   See also: FOPEN, VERSION_DECODE

version_string = [];
version = [];
fseek(fid,0,'bof');
q = 0;
while q~=-1,
    q = fgetl(fid);
	inds = find(q~=' '); q = q(inds(1):end);
    if any(strfind(q,'<PVScan version=')),
        version_string = sscanf(q,'<PVScan version="%s" date');
        q = -1;
    end;
end;

version_string = version_string(find(version_string~='"')); % remove these

fseek(fid,0,'bof');

if ~isempty(version_string),
    version = version_decode(version_string);
end;
