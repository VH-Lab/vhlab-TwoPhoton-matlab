function fname=tpfilename(tpfileparams,cycle,channel,frame)
% TPFILENAME - Determine a 2-photon file name for Insopix data
 % ignore channel for now

if channel>1, error(['Only 1 channel.']); end;

cycle_string = ['Cycle_' int2str(cycle)];

fname= getfield(  getfield(tpfileparams,cycle_string), 'filename' );
