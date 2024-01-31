function b = stack2ndi(tpstack_file, S, subjectname)
% STACK2NDI - export data from a vhlab-TwoPhoton-matlab to an NDI session
%
% B = STACK2NDI(TPSTACK_FILE, S, subjectname)
%
% Given a stack file TPSTACK_FILE and an ndi.session S, and the subjectname,
% export the subject and neurons.
%
% Needs to have subject.txt file in folder (e.g., 'scn1-722@turrigiano.org')
%
% Example: 
%  tpstack_file = '/Volumes/van-hooser-lab/Users/Diane/For_Diane/2722-05-05/analysis/scratch/stack1.stack';
%  S = ndi.setup.vhlab('2722','/Users/vanhoosr/Desktop/2722-05-05');
%  S = ndi.session.dir('/Volumes/van-hooser-lab/Users/Diane/For_Diane/2722-05-05');
%  b = stack2ndi(tpstack_file,S);
%
%

[tppath,sitename,ext] = fileparts(tpstack_file);

tpstack = load(tpstack_file,'-mat');

subjectname = vlt.file.textfile2char([S.path() filesep 'subject.txt']);
s_q = ndi.query('base.name','exact_string',subjectname) & ndi.query('','isa','subject');

s = S.database_search(s_q);

if isempty(s),
	error(['Oh, I didn't find a subject.']);
end;

subdoc = s{1};
subdoc_id = subdoc.id();

 % get visual stimulator here

decoder = ndi.app.stimulus.decoder(S);
rapp = ndi.app.stimulus.tuning_response(S);

p = S.getprobes('type','stimulator');
if isempty(p), error(['Could not find stimulator.']); end;
decoder.parse_stimuli(p{1},0);
cs_doc = rapp.label_control_stimuli(p{1},0);

stimulator_id = p{1}.id();

pres = S.database_search(ndi.query('','isa','stimulus_presentation'));

srp = ndi.document('stimulus_response_scalar_parameters_basic') + S.newdocument();
srp_struct = srp.document_properties.stimulus_response_scalar_parameters_basic;
srp_struct.prestimulus_time = 5;
srp_struct.prestimulus_normalization = 3;
srp = ndi.document('stimulus_response_scalar_parameters_basic',...
		'stimulus_response_scalar_parameters_basic',srp_struct) + S.newdocument();

S.database_add(srp);

srp_id = srp.id();

ds = dirstruct(S.path());

T = getalltests(ds);

nde = {};
nde_id = {};
cellnames = {};

for t=1:numel(T),

	% Step 1: add all new cells as ndi.elements
if 0,
	for i=1:numel(tpstack.celllist),
		if strcmp(T{t},tpstack.celllist(i).dirname),
			cellname_here = ['cell ' int2str(tpstack.celllist(i).index) ' ref ' ...
				tpstack.celllist(i).dirname]
			disp(['...making element...']);
			cellnames{end+1} = cellname_here;
			nde{end+1} = ndi.element.timeseries(S,cellname_here, 1,'roi',[],0,subdoc_id);
			nde_id{end+1} = nde{end}.id();
		end;
	end;
end;

	%which stim_pres do we have?

	stim_index = [];
	for pr = 1:numel(pres),
		if strcmp(pres{pr}.document_properties.epochid.epochid,T{t}),
			stim_index = pr;
			break;
		end;
	end;
	control_stim_index = [];
	for pr = 1:numel(cs_doc),
		if strcmp(cs_doc{pr}.dependency_value('stimulus_presentation_id'),pres{stim_index}.id()),
			control_stim_index = pr;
			break;
		end;
	end;

	% load responses, add responses from all cells recorded here

	resp_struct = load([getpathname(ds) filesep T{t} filesep sitename '_' T{t} '.mat']);

	stim_response_doc = {};
	for i=1:numel(resp_struct.listofcellnames),
		disp(['Working on cell ' int2str(i) ' of ' int2str(numel(resp_struct.listofcellnames))])
		index = find(strcmp(resp_struct.listofcellnames{i},cellnames));
		stim_response_doc{i} = stackresp2ndiresponsedoc(S,T{t},resp_struct.resps(i),...
			pres{stim_index},cs_doc{control_stim_index},nde_id{index},stimulator_id,srp_id);
		S.database_add(stim_response_doc{i});
	end;
end;

