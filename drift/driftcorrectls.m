function [dr] = driftcorrectls(orig_imag, linescanpoints, linescandata, searchX, searchY, brightnesscorrect);

 % driftcorrect  -- the correction of the original image
 % driftcorrect_ls  -- the correction of the line scans


usemse = 1;

imsize = size(orig_imag);

imscan = NaN(length(searchX)*length(searchY),size(linescanpoints,1));

 % someday this should be replaced with a mex file

ins = 1;
dloc = [ ];
for i=1:length(searchX),
    for j=1:length(searchY),
        dloc(end+1,:) = [ i j];
	inds = linescan2rasterindex(imsize,[linescanpoints(:,1)-searchY(j) linescanpoints(:,2)-searchX(i)]);
        goodinds = find(inds>0&~isnan(inds));
        imscan(ins,goodinds) = orig_imag(inds(goodinds));
        if brightnesscorrect, imscan(ins,:) = imscan(ins,:)./max(imscan(ins,:)); end;
        ins = ins + 1;
    end;
end;

if brightnesscorrect, linescandata = linescandata./max(linescandata); end;

if usemse,
	mse = (imscan - repmat(linescandata,length(searchX)*length(searchY),1)).^2;
	[mn,loc] = min(sum(mse,2));
else, % use correlation
	xc = imscan .* repmat(linescandata,length(searchX)*length(searchY),1);
	[mx,loc] = max(nanmean(xc,2));
end;

dr = [searchX(dloc(loc,1)) searchY(dloc(loc,2))];
