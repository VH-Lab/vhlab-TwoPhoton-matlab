function suite2p_importcells2stack(suite2p_Fall_file,lead_t,tpstack_file)
% SUITE2P_IMPORTCELLS2STACK - import cell drawings from Suite2p to vhlab-TwoPhoton-matlab
%
% SUITE2P_IMPORTCELLS2STACK(SUITE2P_Fall_FILE, LEAD_T_DIR, TPSTACK_FILE)
%
% Imports SUITE2P cell ROIs into vhalb-TwoPhoton-matlab stacks
%
% SUITE2P_FALL_FILE should be the Fall.mat file name for a Suite2p plane.
% For example: 
%    suite2p_Fall_file = '/Volumes/van-hooser-lab/Users/Diane/For_Steve/SCN-722/t00001-001/suite2p/plane0/Fall.mat'
%
% LEAD_T_DIR is the leading test directory name (if there is a set of multiple test directories merged in
% suite2p, use the first one) (5 total digits):
% lead_t_dir = 't00001'  
%
% TPSTACK_FILE should be the name of a vhlab-TwoPhoton-matlab stack file
% For example:
%   tpstack_file = '/Volumes/van-hooser-lab/Users/Diane/For_Diane/2722-05-05/analysis/scratch/stack1.stack'

Fall = load(suite2p_Fall_file);

stack_data = load(tpstack_file,'-mat');

if ~isfield(stack_data,'celllist'),
	stack_data.celllist = vlt.data.emptystruct('dirname','pixelinds',...
		'xi','yi','index','type','labels');
end;

max_index = 0;

if ~isempty(stack_data.celllist),
	max_index = max([stack_data.celllist.index]);
end;

 % now add the cells

for i=1:numel(Fall.stat),
	celllist_here = [];
	celllist_here.dirname = lead_t;
	celllist_here.pixelinds = sub2ind(size(Fall.ops.meanImgE),...
		Fall.stat{i}.xpix,Fall.stat{i}.ypix);
	celllist_here.xi = Fall.stat{i}.xcirc;
	celllist_here.yi = Fall.stat{i}.ycirc;
	celllist_here.index = max_index + 1;
	celllist_here.type = 'cell';
	celllist_here.labels = {'GCaMP'};
	stack_data.celllist(end+1) = celllist_here;
	max_index = max_index + 1;
end;

celllist = stack_data.celllist;

save(tpstack_file,'celllist','-append','-mat');

