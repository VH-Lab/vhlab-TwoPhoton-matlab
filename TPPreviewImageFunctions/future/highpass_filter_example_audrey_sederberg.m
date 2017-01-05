% In the Dropbox folder, I put abbreviated movies from one experiment 
% showing the difference between filtering and not filtering. 
% 'exp5d1B_raw' is the unfiltered (raw) version (made of 'M0's, below); 
% 'exp5d1_hpf' is the filtered version. A single image could be created with
% the code below: change 't000XXX' to read the actual image file name.


hl = fspecial('gaussian', 60, 15);		% creates a 60x60 pixel gaussian 
                                        % low-pass filter with sigma = 15

M0 = imread('t000XXX', 'tif');			% 't000XXX' is the image file name, 
                                        % 'tif' is the format
                                        
bkgdIM = imfilter(M0, hl, 'symmetric');	% imfilter does the 2D filtering, 
                                        % returning the low-pass filtered 
                                        % image (the background)
                                        
M = M0 - bkgdIM;						% what remains is the high-passed 
                                        % image -- so the cells are more 
                                        % obvious
                                        
figure()
subplot(121)
imagesc(M0)
colormap gray
axis square
subplot(122)
imagesc(M)
colormap gray
axis square

%% this iterates the process, adding a low-pass filter to removes some of 
% the speckling. This is an example of a frame from 'exp5d1_bpf'

hl = fspecial('gaussian', 60, 15);		% gaussian filter, sigma = 15
hh = fspecial('gaussian', 8, 2);		% gaussian filter, sigma = 2
	
bkgdIM = imfilter(M0, hl, 'symmetric');	
MBP = imfilter(M0 - bkgdIM, hh, 'symmetric');

figure()
subplot(121)
imagesc(M0)
colormap gray
axis square
subplot(122)
imagesc(MBP)
colormap gray
axis square
