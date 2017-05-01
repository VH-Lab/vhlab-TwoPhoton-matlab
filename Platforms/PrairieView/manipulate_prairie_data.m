function manipulate_prairie_data(dirname, channel, shift, rotation)

disp(['Warning!  This script manipulates prairie data with shifts or rotations']);
disp(['Warning!  This should be used only on a COPY of original data, for diagnostic purposes.']);
disp(['Warning!  Document which directory is manipulated, so no one will be confused.']);

disp(['The directory to be modified is ' dirname '.']);

r = input('Do you want to continue? (Y/N): ','s');

if ~strcmp(toupper(r),'Y'), disp(['Okay, not doing anything.']); return; end;
    

tpdirname = [dirname '-001'];

if ~exist(tpdirname),
	error(['Directory ' tpdirname ' does not exist.']);
end;

pcfile = dir([tpdirname filesep '*_Main.pcf']);
if isempty(pcfile), pcfile = dir([tpdirname filesep '*.xml']); end;
pcfile = pcfile(end).name;
params = readprairieconfig([tpdirname filesep pcfile]);
tpfileparams = tpfnameparams(tpdirname,channel,params);

if isfield(params,'Type'),
	if strcmp(params.Type,'Linescan')|strcmp(params.Type,'linescan'),
        error(['It is undefined to use this procedure on linescans.']); 
	end;
end;

ffile = repmat([0 0],length(params.Image_TimeStamp__us_),1);

initind = 1;
for i=1:params.Main.Total_cycles,
  frames=getfield(getfield(params,['Cycle_' int2str(i)]),'Number_of_images');
  ffile(initind:initind+frames-1,:) = [repmat(i,frames,1) (1:frames)'];
  initind = initind + frames;
end;

for i=1:size(ffile,1),

    im_original = double(imread(fullfile(tpdirname,tpfilename(tpfileparams,ffile(i,1),channel,ffile(i,2)))));
    
    sz = size(im_original);
    
    [X,Y] = meshgrid(linspace(-sz(1)/2,sz(1)/2,sz(1)),linspace(-sz(2)/2,sz(2)/2,sz(2)));
    
    [XYn] = (rot2d(rotation*pi/180)*[X(:) Y(:)]')';

    Xn = XYn(:,1) + shift(1); Yn = XYn(:,2) + shift(2);
    
    Xn = reshape(Xn,size(X,1),size(X,2)); 
    Yn = reshape(Yn,size(Y,1),size(Y,2));
    
    im_modified = interp2(X,Y,im_original,Xn,Yn);

    imwrite(uint16(im_modified),fullfile(tpdirname,tpfilename(tpfileparams,ffile(i,1),channel,ffile(i,2))));

    disp(['Processed raw frame ' int2str(i) ' of ' int2str(size(ffile,1)) '.']);

end;


