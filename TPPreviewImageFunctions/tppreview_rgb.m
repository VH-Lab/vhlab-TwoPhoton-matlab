function [ims,channels] = tppreview_rgb(dirnames, tpparams, channellist, parameters)

channels = [];

% lets find parameter files, get the file name prefix pattern

  % allow user to choose R, G, and B image; user can choose among other preview images from directories recorded at the same time
  %      problem:  how to pass name/ref?
  %          one is to try to identify a callback figure and pull the name/ref from that directory
  %          or, just assume that there will only be a single 2-photon record per directory; probably reasonable
  % 
  %      next problem: what if user wants to pull up views that haven't been computed yet?
  %          could call TPPreviewImageCompute on that directory; probably the best option
  %            	okay, how do we stop it from running itself recursively?

ims = [];

 % this is an interactive-only, so return empty if it was called by TPPreviewImageFunctionListCompute
stack = dbstack;
if strcmp(stack(2).name, 'TPPreviewImageFunctionListCompute'),
	return;
end;

 % now we are sure we are interactive; now go ahead and work

 % make sure all non-interactive tppreview images have been computed

currdir = nontpdirname(dirnames{1});  % find out the name of the test directory, might be different from tpdir

TPPreviewImageFunctionListCompute(currdir);

 % find the other directories that are valid for us to choose

[experdir,dirpathname] = fileparts(currdir);

ds = dirstruct(experdir);
namerefs = getnamerefs(ds,dirpathname);

tpnameref = [];
for i=1:length(namerefs),
	if strcmp(namerefs(i).type,'prairietp'),
		tpnameref = namerefs(i);
	end;
end;

if isempty(tpnameref),
	error(['No reference with type ''prairietp'' found.']);
end;

validdirlist = gettests(ds,tpnameref.name,tpnameref.ref);

img = [];

colors = {'RED','GREEN','BLUE'};

for i=1:3,
	[s,v] = listdlg('PromptString',['Select directory for ' colors{i} ' image:'],...
		'SelectionMode','single',...
		'ListString',validdirlist);

	if isempty(v), % user clicked cancel, cancel the whole thing
		ims = [];
		return;
	else,
		TPPreviewImageFunctionListCompute(fullfile(experdir,validdirlist{s}));
		dirlist = dir(fullfile(experdir,validdirlist{s},'tppreview_*'));
		[s2,v2] = listdlg('PromptString',['Select preview file: '],'SelectionMode','single',...
			'ListString',{dirlist.name});
		if isempty(v2), % user clicked cancel, cancel the whole thing
			ims = [];
			return;
		else,
			z = load(fullfile(experdir,validdirlist{s},dirlist(s2).name));
			if isempty(img),
				img = z.pvimg(:,:,1);
			else,
				img(:,:,i) = z.pvimg(:,:,1);
			end;
		end;
	end;
end;

  % copy to all channels requested
for j=1:length(channellist),
	ims{j} = img;
	channels(j) = channellist(j);
end;

