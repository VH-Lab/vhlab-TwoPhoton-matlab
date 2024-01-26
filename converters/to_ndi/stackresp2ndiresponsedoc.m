function [stim_response_doc] = stackresp2ndiresponsedoc(resp_struct, nde, options)
%
% STIM_RESP_DOC = STACKRESP2NDIRESPONSEDOC(RESP_STRUCT)
%

stim_response_doc = [];

index = find(strcmp(nde.name,resp_struct.list_of_cellnames));

responses = vlt.data.empty_struct('stimid','response_real','response_imaginary',...
	'control_response_real','control_response_imaginary');

if ~isempty(index),
	for i=1:numel(resp_struct.resps(index).ind),
		response_here = [];
		response_here.stimid = i;
		response_here.response_real = resp_struct.resps(index).ind{i};
		response_here.response_imaginary = 0;
		response_here.control_response_real = resp_struct.resps(index).blankind(i);
		response_here.control_response_imaginary = 0;
		responses(end+1) = response_here;
	end;
end;

stimulus_response_scalar.response_type = 'mean';
stimulus_response_scalar.responses = responses;

stim_response_doc = ndi.document('stimulus_response_scalar',...
	'stimulus_response_scalar',stimulus_response_scalar) + S.newdocument();

stim_response_doc = stim_response_doc.set_dependency('element_id,options.element_id);

stim_response_doc = stim_response_doc.set_dependency('stimulator_id',options.stimulator_id);


stim_response_doc = stim_response_doc.set_dependency('stimulus_response_scalar_parameters_id',...
	options.stimulus_response_scalar_parameters_basic);


stim_response_doc = stim_response_doc.set_dependency('stimulus_control_id',options.stimulus_control_id);
stim_response_doc = stim_response_doc.set_dependency('stimulus_presentation_id',...
	options.stimulus_presentation_id);
