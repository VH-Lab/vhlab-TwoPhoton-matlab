function nontp = nontpdirname(dirname)
% NONTPDIRNAME - Return test directory associated with a given two-photon directory
%
%   NONTPDIR = NONTPDIRNAME(DIRNAME)
%
%   Given a 2-photon directory name DIRNAME, return the associated test directory,
%   which may or may not be the same.  This is the inverse of the function
%   TPDIRNAMES.
%
%   See also: TPDIRNAMES

nontp = dirname;
if iscell(nontp),
	nontp = nontp{1};
end;

z = find(nontp=='-');
nontp = nontp(1:z(end)-1);
