function [overlap_raw,overlap_norm,labelnum]= maskoverlap(labeledmask1,mask2)

% MASKOVERLAP - Compute overlap of spots from 2 masks
%
%  [OVERLAP_RAW,OVERLAP_NORM,LABELNUM]=MASKOVERLAP(LABELEDMASK1,mask2)
%
%  Computes the 'overlap' of each spot in the labeled mask 
%  LABELEDMASK1 (labeled with a function like BWLABEL) with a secondary
%  mask MASK2 (need not be labeled, but it could be).
%  The labeled mask number of each mask is returned in LABELNUM.
%
%  OVERLAP_RAW returns the raw number of pixels that overlap.  
%  OVERLAP_NORM returns the overlap in terms of the size of the
%      each labeled spot in LABELED_MASK1 (ranging from 0 to 1).

overlap_raw = [];
overlap_norm = [];
labelnum = [];

labelnum = setdiff(unique(labeledmask1(:)),0);

for i=1:length(labelnum),
	pixinds = find(labeledmask1==labelnum(i));
	overlap_raw(end+1) = sum(mask2(pixinds)>0);
	overlap_norm(end+1) = overlap_raw(end)/length(pixinds);
end;
  


