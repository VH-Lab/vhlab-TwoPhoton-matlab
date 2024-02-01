function [stim_response_doc] = stackresp2ndiresponsedoc(S, tdir, resp_struct, stim_presentation, control_stim_presentation, nde_id, stimulator_id, srp_id)
%
% STIM_RESP_DOC = STACKRESP2NDIRESPONSEDOC(RESP_STRUCT)
%

stim_response_doc = [];

responses = struct('stimid',[], 'response_real',[], 'response_imaginary',[],...
	'control_response_real',[],'control_response_imaginary',[]);

all_stims = unique(stim_presentation.document_properties.stimulus_presentation.presentation_order);

stim_counters = zeros(numel(all_stims),1);
blank_counter = 0;

c_stim_id = control_stim_presentation.document_properties.control_stimulus_ids.control_stimulus_ids;

for i=1:numel(stim_presentation.document_properties.stimulus_presentation.presentation_order),
	responses.stimid(i) = stim_presentation.document_properties.stimulus_presentation.presentation_order(i);
	j = find(responses.stimid(i) == all_stims);
	if j<numel(all_stims), % regular stimulus
		stim_counters(j) = stim_counters(j)+1;
		responses.response_real(i) = resp_struct.ind{j}(stim_counters(j));
		responses.response_imaginary(i) = 0;
	else,
		blank_counter = blank_counter + 1;
		responses.response_real(i) = resp_struct.blankind(blank_counter);
		responses.response_imaginary(i) = 0;
	end;

	responses.control_response_real(i) = 0; 
	responses.control_response_imaginary(i) = 0;
end;

for i=1:numel(c_stim_id),
	responses.control_response_real(i) = responses.response_real(c_stim_id(i));
end;

stimulus_response_scalar.response_type = 'mean';
stimulus_response_scalar.responses = responses;

stimulus_response_struct.stimulator_epochid = tdir;
stimulus_response_struct.element_epochid = tdir;

stim_response_doc = ndi.document('stimulus_response_scalar',...
	'stimulus_response_scalar',stimulus_response_scalar,...
	'stimulus_response',stimulus_response_struct) + S.newdocument();

stim_response_doc = stim_response_doc.set_dependency_value('element_id',nde_id);

stim_response_doc = stim_response_doc.set_dependency_value('stimulator_id',stimulator_id);

stim_response_doc = stim_response_doc.set_dependency_value('stimulus_response_scalar_parameters_id',...
	srp_id);

stim_response_doc = stim_response_doc.set_dependency_value('stimulus_control_id',control_stim_presentation.document_properties.base.id);
stim_response_doc = stim_response_doc.set_dependency_value('stimulus_presentation_id',stim_presentation.document_properties.base.id);

