function [stim_response_doc] = stackresp2ndiresponsedoc(S, tdir, resp_struct, stim_presentation, control_stim_presentation, nde_id, stimulator_id, srp_id)
%
% STIM_RESP_DOC = STACKRESP2NDIRESPONSEDOC(RESP_STRUCT)
%

stim_response_doc = [];

responses = vlt.data.emptystruct('stimid','response_real','response_imaginary',...
	'control_response_real','control_response_imaginary');

all_stims = unique(stim_presentation.document_properties.stimulus_presentation.presentation_order);

stim_counters = zeros(numel(all_stims),1);
blank_counter = 0;

c_stim_id = control_stim_presentation.document_properties.control_stimulus_ids.control_stimulus_ids;

for i=1:numel(stim_presentation.document_properties.stimulus_presentation.presentation_order),
	response_here = [];
	response_here.stimid = stim_presentation.document_properties.stimulus_presentation.presentation_order(i);
	j = find(response_here.stimid == all_stims);
	if j<numel(all_stims), % regular stimulus
		stim_counters(j) = stim_counters(j)+1;
		response_here.response_real = resp_struct.ind{j}(stim_counters(j));
		response_here.response_imaginary = 0;
	else,
		blank_counter = blank_counter + 1;
		response_here.response_real = resp_struct.blankind(blank_counter);
		response_here.response_imaginary = 0;
	end;

	response_here.control_response_real = 0; 
	response_here.control_response_imaginary = 0;
	responses(end+1) = response_here;
end;

for i=1:numel(c_stim_id),
	responses(i).control_response_real = responses(c_stim_id(i)).response_real;
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

