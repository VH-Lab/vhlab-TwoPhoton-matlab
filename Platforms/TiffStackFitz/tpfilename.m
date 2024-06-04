function fname=tpfilename(tpfileparams,cycle,channel,frame)
% TPFILENAME - Determine a 2-photon file name for TIFFSTACK data
 % ignore channel for now

cycle_string = ['Cycle_' int2str(cycle)];

fname= getfield(  getfield(tpfileparams,cycle_string), 'filename' );

fname(8) = int2str(channel);
