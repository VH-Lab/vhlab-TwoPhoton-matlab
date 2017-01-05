function drawGCaMPcells(parameters, inputs)
% DRAW_GCAMP- Import a cell list from drawing of centroids.
%
%   CELLLIST = DRAW_GCAMP(PARAMETERS, INPUTS)
%
%     PARAMETERS should be a structure with the following entries:
%        cellDiameterMin  Cell minimum diameter (pixels) (default 6)
%        cellDiameterMax  Cell maximum diameter (pixels) (default 14)
%        channel          Channel to be read
%        houghCutoff      Hough Cutoff parameter (default 40000);
%                          The Hough cutoff is the way to adjust sensitivity.
%                          It's a threshold value. Any pixel in the Hough
%                          image above the cutoff will be considered a seed point.
%                          Lower the cutoff for more sensitivity, raise it for less.
%                          One way to get at this number quickly is to run the program once with it
%                          at a high cutoff (say, 60000) and look at the accumMax.png output image.
%                          Find the lowest peak in accumMax that corresponds to a cell, and put the
%                          value in here.
%                          Note that setting it very low will dramatically increase runtime, as many
%                          more candidate cells will be found.
%       scoreThresh       The required score for something to be a cell. 1.5~2.0 is good (default 2)
%                          Score is the mean of the edge intensity divided by the standard deviation.
%                          So an edge needs to be (1) strong and (2) consistent in intensity 
%                          as it travels around the cell. Lower this if you have a lot of half-cells
%                          you want to find, or to push up sensitivity.
%       imageBitDepth     (Default 13)
%       gradientThreshold (Default 0.1) (fraction of 2^(imageBitDepth)-1 to use as threshold)
%       gaussianSigma     (Default 1.2) (Sigma of the gaussian filter)
%       gaussianSize      (Default 7) (How large the box containing the gaussian filter is)
%       minRequiredEvents (Default 1) Require a cell to show up at least this many times to be detected
%
%
%     INPUTS is the standard ANALYZETPSTACK_DRAW_DEVICE input structure with fields
%         previewim                 The current directory's preview image
%                                               (the NxM pixel image)
%         fullpathdirname           The full path of the directory being examined
%         dirname                   The dirname being examined
%         drift                     The calculated "shift" between this image and the
%                                       first image in the sequence of images that
%                                       were collected at this location (note that
%                                       this may be a shift onto a previous
%                                       recording if 2 or more recordings were made at
%                                       the same location).
%         ds                        A directory structure object for traversing the
%                                       file structure for the entire experiment.
%         default_type_string       The type string that is currently selected
%         default_label_strings     A cell list of the currently selected label strings
%         cell_index_counter        The current value of the cell index counter.
%
%      CELLLIST is a structure list of cell information as described in
%          ANALYZETPSTACK_EMTPYCELLREC
%





% GCaMP cell detection, formulated to run offline between imaging runs. 
% Process is:
% (1) Subtract the previous image to get a derivative image
% (2) Correct intensity differences from scope
% (3) Find the image gradient (Prewitt edge detector)
% (4) Run the Hough transform on the gradient (Peng 2007)
% (5) Combine nearby peaks using a small Gaussian filter
% Then, for each peak in the Hough:
% (6) Polar transform and trace cell edge (Nandy 2007)
% (7) Keep or exclude cell based on edge score (mean/std)
% (8) Combine cell with any other copies of itself (radius based, DBSCAN)

% ========================================== %

outputDir = pathstr2cellarray(userpath);

% ========================================== %
% Parameters you can probably leave alone

% The gradient threshold determines what will be considered as a possible
% cell. All this does is eliminate parts of the gradient that are clearly 
% noise so we don't spend any processor time looking at them. You probably
% won't need to change this.
imageMaxValue = 2^(parameters.imageBitDepth)-1; 
gradientThreshold = imageMaxValue * parameters.gradientThreshold;

% The expected distance between two cells.
% If the algorithm appears to be excluding ROIs that are near each other,
% make this lower.
% If it is drawing many ROIs very close together, make this higher.
% Usually using something near the average radius works well.
minDistBetweenCells = (parameters.cellDiameterMax) / 2; 

% ========================================== %
% End input parameters -- code starts here

rMin = parameters.cellDiameterMin / 2;
rMax = parameters.cellDiameterMax / 2;
radrange = [rMin,rMax];
numRadii = length(rMin+0.5:rMax); % might be useful for auto-calculation of Hough cutoff?

% ========================================== %
% Find derivative images
disp('Calculating time derivative images');



zEdgeFilter = zeros(3,3,3);

p = tpreadparams(inputs.fullpathdirname);
  % SV edit here



derivTifs = tifs(:,:,2:end) - tifs(:,:,1:end-1);

writeTifs(derivTifs,[outputDir 'derivTifs/']);
derivMax = max(derivTifs,[],3);
writeDoubleTif(derivMax,[outputDir 'derivMax.tif']);

[height width nFrames] = size(derivTifs);


% ========================================== %
% Find the image gradient (Prewitt edge detector)
grdMagTifs = zeros(size(derivTifs));
accumTifs = zeros(size(derivTifs));
cellOutlines = zeros(size(derivTifs));

s=1; %index
numDrawn = 0;
clear seeds;
accumulatedCellOutlines = zeros(size(derivTifs));
for t=1:nFrames
    if mod(t,10)==9
        disp([num2str(100*t/nFrames) '% completed.']);
    end
    % get derivative frame
    frame = double(derivTifs(:,:,t));
    
    % Prewitt filter to get gradients
    prewittX = [
        1 0 -1
        1 0 -1
        1 0 -1];
    prewittY = [
        1 1 1
        0 0 0
        -1 -1 -1];

    gradientX = conv2(frame, prewittX, 'valid');
    gradientY = conv2(frame, prewittY, 'valid');

    gradientX = addBorder(gradientX,0); %pad to original image size
    gradientY = addBorder(gradientY,0); %pad to original image size

    gradientMag = sqrt(gradientX.^2 + gradientY.^2);
    grdMagTifs(:,:,t) = gradientMag;
    
    % ========================================== %
    % Hough transform to find circles (Peng 2009)
    accum = CircularHough_Grd(gradientX, gradientY, radrange, gradientThreshold);

    % ========================================== %
    % Combine nearby peaks using a small Gaussian filter
    f = fspecial('gaussian',parameters.gaussianSize,parameters.gaussianSigma);
    accum = imfilter(accum,f);
    accumTifs(:,:,t) = accum;
    
    % the centroids of each blob will be our seeds
    accumThresh = accum > parameters.houghCutoff; % this is OK for now; think about it later
    CC = bwconncomp(accumThresh);
    STATS = regionprops(CC,'Centroid');
    centroidImg = zeros(size(accumThresh));
    
    if isempty(STATS)
        continue;
    end
    
    % ========================================== %
    % Polar transform and trace cell edge (Nandy 2007)
    cellOutline = zeros(size(frame));
    foundCell = false;
    for i=1:length(STATS)
        seed.edgeSeedPoint = [round(STATS(i).Centroid(2)),round(STATS(i).Centroid(1))];
        seedStats = gcampSeedStats(seed, frame, parameters.cellDiameterMin, parameters.cellDiameterMax);

        if seedStats.removed==1
            % bad ROI; couldn't fit a circular edge to it. 
            continue;
        end
        if seedStats.score < scoreThresh
            % We managed to fit a circular edge, but it was a crappy one.
            continue;
        end
        
        % Take the polar image at each seed point
        seeds{s}.edgeSeedPoint = [round(STATS(i).Centroid(2)),round(STATS(i).Centroid(1))];
        seeds{s}.outlineX = seedStats.outlineX;
        seeds{s}.outlineY = seedStats.outlineY;
        seeds{s}.enclosedX = seedStats.enclosedX;
        seeds{s}.enclosedY = seedStats.enclosedY;
        seeds{s}.score = seedStats.score;
        seeds{s}.t = t;
         
        %draw cellOutline image for cells with a good score
        X=seeds{s}.outlineX;
        Y=seeds{s}.outlineY;
        for j=1:length(X)
            x=Y(j);
            y=X(j);
            cellOutline(x,y) = 1;
        end
        numDrawn = numDrawn+1;
        
        s=s+1;
        foundCell = true;
    end
    if foundCell
        disp(['  ' num2str(length(seeds)) ' cell events found.']);
    end
    cellOutlines(:,:,t) = cellOutline;
end

% write some output data
writeTifs(grdMagTifs,[outputDir 'grdMagTifs/']);
imwrite(uint16(max(grdMagTifs,[],3)),[outputDir 'grdMagMax.tif'],'tif');

writeTifs(accumTifs,[outputDir 'accumTifs/']);
imwrite(uint16(max(accumTifs,[],3)),[outputDir 'accumMax.tif'],'tif');

writeTifs(cellOutlines,[outputDir 'cellOutlines/']);
imwrite(uint16(max(cellOutlines,[],3)),[outputDir 'cellOutlinesMax.tif'],'tif');

% clean up excess data; we only made these for debugging and performance
% tuning, so they can be removed from the final version entirely.
% writeTifs(grdMagTifs,'grdMagTifs');
% writeTifs(accumTifs,'accumTifs');
clear grdMagTifs;
clear accumTifs;
clear cellOutlines;


% ========================================== %
% Combine cell with any other copies of itself (radius based, DBSCAN)
disp('combining frame ROIs to cells');
% Use DBSCAN to find unique cells.
points = zeros(length(seeds),2);
for s=1:length(seeds)
    points(s,:) = seeds{s}.edgeSeedPoint;
end

% run dbscan
clusterLabels = dbscan(points,parameters.minRequiredEvents-1,minDistBetweenCells);

clear cells;
%set up the cells data structure
for c=1:max(clusterLabels)
    cells{c}.clusterSize = length(find(clusterLabels == c));
    cells{c}.maxScore = 0;
end

% assign each cell the outline that had the best score
for s=1:length(seeds)
    c = clusterLabels(s);
    if c <= 0
        continue;
    end
    if seeds{s}.score > cells{c}.maxScore
        cells{c}.maxScore = seeds{s}.score;
        cells{c}.outlineX = seeds{s}.outlineX;
        cells{c}.outlineY = seeds{s}.outlineY;
        cells{c}.enclosedX = seeds{s}.enclosedX;
        cells{c}.enclosedY = seeds{s}.enclosedY;
        cells{c}.t = seeds{s}.t;
    end
end

% ========================================== %
% Do final output
% write out the cells into a cellOutlines image
cellOutline = zeros(height,width);
for c=1:length(cells)
    X=cells{c}.outlineX;
    Y=cells{c}.outlineY;
    for j=1:length(X)
        x=Y(j);
        y=X(j);
        cellOutline(x,y) = 1;
    end
end
writeDoubleTif(cellOutline,[outputDir 'cellOutline.tif']);


% Show an RGB image of the results
figImage = uint8(repmat(derivMax,[1 1 3]) * (255/max(max(derivMax))));
figImage(:,:,2) = figImage(:,:,2) + uint8(255*cellOutline);
imshow(figImage)


disp('Done! Data is now in the variable "cells".');
