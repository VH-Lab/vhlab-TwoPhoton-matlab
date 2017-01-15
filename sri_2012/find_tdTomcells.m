function [tdTom_pos_centroids,tdTom_neg_centroids]=find_tdTomcells(tdTom_image,fura_image,pixel_size_per_cell)
% [tdTom_pos_centroids,tdTom_neg_centroids]=find_tdTomcells(tdTom_image,fura_image,pixel_size_per_cell)
% calculates centroids for tdTomato positive cells
% Input
%   tdTom_image
%   fura_image
%   pixel_size_per_cell: minimum pixel size for each cell
% Output
%   tdTom_pos_centroids: centroids of fura cells that are tdTom positive
%   tdTom_neg_centroids: centroids of fura cells that are tdTom negative

[tdTomRes, tdTomMask] = spotDetector(tdTom_image);
[furaRes, furaMask] = spotDetector(fura_image);


 % edit the masks to remove cells that are too small

tdTomLabel=bwlabel(tdTomMask,4);
for ii=1:max(tdTomLabel(:))
    cell_size(ii)=nnz(find(tdTomLabel==ii));
end;

   % exclude spots that are too small to be cells
for ii=1:max(tdTomLabel(:))
    if(cell_size(ii)<=pixel_size_per_cell)
        tdTomMask(find(tdTomLabel==ii))=0;
    end
end

furaLabel=bwlabel(furaMask,4);
for ii=1:max(furaLabel(:))
    fura_cell_size(ii)=nnz(find(furaLabel==ii));
end;
  % exclude guys that are too small
for ii=1:max(furaLabel(:))
    if(fura_cell_size(ii)<=pixel_size_per_cell)
        furaMask(find(furaLabel==ii))=0;
    end
end

  % examine trimmed masks for overlap

tdTom_fura_positive=furaMask.*tdTomMask;
tdTom_active_centroids=regionprops(logical(tdTom_fura_positive),'centroid');  % centroids that are tdTom and fura positive
fura_centroids=regionprops(logical(furaMask),'centroid'); % centroids that are fura positive; everyone is fura positive

 % double-labeled cells could be described by an overlap percentage

for itom=1:length(tdTom_active_centroids)  % for each tdTom+fura centroid...
    x1=tdTom_active_centroids(itom).Centroid;
    clear dist;
    for ii=1:length(fura_centroids)  % examine distance between it and all fura positive centroids
        yi=fura_centroids(ii).Centroid;
        dist(ii)=norm(x1-yi);
    end;
    [idum,val]=min(dist);  % find the closest one; we assume there will be one
    tdTom_cells(itom)=val;  % this is the closest one
    tdTom_pos_centroids(itom,:)=fura_centroids(val).Centroid;
end;

for ii=1:324  % I think we mean length(fura_centroids) instead of a specific number?
    all_centroids(ii,:)=fura_centroids(ii).Centroid;
end;


tdTom_neg_centroids=all_centroids(setdiff(1:length(all_centroids),tdTom_cells),:);
