function vhlab2p_movecells2firstdirectory(filename)
% VHLAB2P_MOVECELLS2FIRSTDIRECTORY - relabel all cells as being "drawn" in first drawn directory
%
% VHLAB2P_MOVECELLS2FIRSTDIRECTORY(FILENAME)
%
% Given an ANALYZETPSTACK '.stack' file FILENAME, this function reads in the
% definition for all drawn cell ROIs and changes the directory where the cell
% was "first" drawn to be the first directory. The directories are assumed
% to be in alphanumeric order.
%
% A new stack file is saved: [(FILENAME without .stack)-alt.stack].
%
% That new stack can then be loaded into ANALYZETPSTACK windows.
%

load(filename,'-mat');

dnames = unique({celllist.dirname});

for i=1:numel(celllist),
	celllist(i).dirname = dnames{1};
end;

clear dnames

varnames = fieldnames(workspace2struct);
varnames = setdiff(varnames,'filename');

[parentdir,fname,ext] = fileparts(filename);

newfilename = fullfile(parentdir,[fname '-alt.stack']);

save(newfilename,varnames{:},'-mat');


