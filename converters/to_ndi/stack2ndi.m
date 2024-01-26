function b = stack2ndi(tpstack_file, S, subjectname)
% STACK2NDI - export data from a vhlab-TwoPhoton-matlab to an NDI session
%
% B = STACK2NDI(TPSTACK_FILE, S, subjectname)
%
% Given a stack file TPSTACK_FILE and an ndi.session S, and the subjectname,
% export the subject and neurons.
%
% Example: 
%  tpstack_file = '/Volumes/van-hooser-lab/Users/Diane/For_Diane/2722-05-05/analysis/scratch/stack1.stack';
%  S = ndi.session.dir('/Volumes/van-hooser-lab/Users/Diane/For_Diane/2722-05-05');
%  b = stack2ndi(tpstack_file,S);
%
%

tpstack = load(tpstack_file,'-mat');

  % Step 1, make sure we have set up the subject

s_q = ndi.query('subject.name','exact_string',subjectname);

s = S.database_search(s_q);

if isempty(s),
	su = ndi.subject(subjectname,'');
	subdoc = su.newdocument() + S.newdocument();
	keyboard; % check to make sure session is on board
	

	S.database_add(subdoc);
else,
	subdoc = s{1};
end;

subdoc_id = subdoc.id();

 % get visual stimulator here

srp = ndi.document('stimulus_response_scalar_parameters_basic') + S.newdocument();

 % Step 3, add the elements

nde = {};

options.stimulus_response_scalar_paramers_id = srp.id();

stim_response_doc = {};

for i=1:numel(tpstack.cellllist),

	nde{i} = ndi.element.timeseries(S,['cell ' tpstack.celllist(i).name],1,'roi',[],0,subdoc_id);

	options.element_id = ndi{i}.id();

	stim_response_doc{i} = stackresp2ndiresponsedoc(resp_struct,nde{i});

	S.database_add(stim_response_doc{i});
end;



