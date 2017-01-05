function cr = emptycellrec

% ANALYZETPSTACK_EMPTYCELLREC - Return an empty cell record
%
%  Returns a structure with the following fields (each empty, ready for filling):
%
%    DIRNAME              :      The dirname where the cell was first identified
%    pixelinds            :      The pixelinds of the cell within the raster image
%                         :           (these index values are actually used to perform
%                         :            ROI analysis)
%    xi                   :      X coordinates of a contour surrounding the cell
%    yi                   :      Y coordinates of a contour surrounding the cell
%                         :           (these xi/yi points are only provided for visualizing
%                         :            the cell locations within the field; they are not
%                         :            actually used to define the ROIs for analysis)
%    index                :      The index number of the cell (a double)
%    type                 :      The type of the cell (a string)
%    labels               :      The labels for these cells (a cell list of strings)
%

cr = struct('dirname','','pixelinds','','xi','','yi','','index',[],'type','','labels','');

