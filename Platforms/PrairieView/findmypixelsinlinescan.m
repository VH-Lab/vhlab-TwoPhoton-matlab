function pixellists = findmypixelsinlinescan(params,impixinds,dr,ims);

imsize = [params.Main.fullImagePixelsPerLine params.Main.fullImageLinesPerFrame];

linesperframe = min(params.Main.Lines_per_frame,size(ims,1));  % actual lines might be less than expected

N = size(params.Linescanpoints,1);  % number of pixels

if isempty(dr),
    xpixels = round(repmat(params.Linescanpoints(:,2)',linesperframe,1));
    ypixels = round(repmat(params.Linescanpoints(:,1)',linesperframe,1));
else,
    xpixels = round(repmat(params.Linescanpoints(:,2)',linesperframe,1) - repmat(dr(:,1),1,N));
    ypixels = round(repmat(params.Linescanpoints(:,1)',linesperframe,1) - repmat(dr(:,2),1,N));
end;

xpixels(find(xpixels<1))=NaN;
ypixels(find(ypixels<1))=NaN;
xpixels(find(xpixels>imsize(1)))=NaN;
ypixels(find(ypixels>imsize(2)))=NaN;

inds = uint32(sub2ind(imsize, xpixels, ypixels));
lspixinds = reshape(1:size(xpixels,1)*N,size(xpixels,1),N);

for i=1:length(impixinds),
    D = zeros(size(inds));
    for jjj=1:length(impixinds{i}), % this is too slow
        D(find((impixinds{i}(jjj)==inds)))=1;
    end;
    pixellists{i} = {};

	if any(D(:)), % weed out cases with no overlap
		for z = 1:size(D,1),
			df = diff([0 D(z,:) 0]);
			ons = find(1==df); % ons, offs should be same lengths
			offs = find(-1==df)-1;
			for j=1:length(ons),
				pixellists{i}{end+1} = lspixinds(z,ons(j):offs(j));
			end;
		end;
	end;
end;

if 0, 
    figure;
    myimg = zeros(imsize);
    myimg(impixinds{1}) = 255;
    myimg(inds) = 128;
    image(myimg); colormap(gray(256));
    
    figure;
    myimg2 = zeros(size(lspixinds));
    for i=1:length(pixellists{1}),
        myimg2(pixellists{1}{i}) = (i/length(pixellists{1}))*255;
    end;
    image(myimg2); colormap(gray(256));
    
end;
