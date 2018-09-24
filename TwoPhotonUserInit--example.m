% TwoPhotonUserInit -a user-editable file to customize the TwoPhoton library's operation
%
%   TWOPHOTONUSERINIT 
%
%   Users can edit this file to add any features specific to your particular user
%   needs
%

analyzetpstack_active_draw_devices('add','import_imagejrois','import_imagejrois',struct('default_filename','RoiSet.zip'));
analyzetpstack_active_draw_devices('add','import_centroids_8','import_centroids',struct('diameter',8));

dsp = struct('min_area',20,'channel_order',[1 2],'overlap',50,'labels1','tdTomato','labels2','FURA','labels3','GFP','labels4','Oregon green','chan1method',0,'chan2method',1,'chan3method',0,'chan4method',0);

analyzetpstack_active_draw_devices('add','drawspots_kade1','drawmarkspots_sri',dsp);

adp20x = struct('localwindowsize',[20 20],'paramC',-0.05,'meanormedian',0,'flare',2,...
        'min_area',120,'max_eccen',2,'min_circularity',0.4,'channel_order',[1 2],'overlap',50,'labels1','tdTomato',...
        'labels2','FURA','labels3','GFP','labels4','Oregon green',...
        'chan1method',0,'chan2method',1,'chan3method',0,'chan4method',0);
analyzetpstack_active_draw_devices('add','adapt20x_kade','draw_adaptivethreshold',adp20x);

adp60x = struct('localwindowsize',[30 30],'paramC',-0.05,'meanormedian',0,'flare',2,...
        'min_area',120,'max_eccen',2,'min_circularity',0.4,'channel_order',[1 2],'overlap',50,'labels1','tdTomato',...
        'labels2','FURA','labels3','GFP','labels4','Oregon green',...
        'chan1method',0,'chan2method',1,'chan3method',0,'chan4method',0);

analyzetpstack_active_draw_devices('add','adapt60x_kade','draw_adaptivethreshold',adp60x);

default_drift_params = driftcorrectbycorrelation_defaultp;
analyzetpstack_active_drift_devices('add','default',...
	'driftcorrectbycorrelation',default_drift_params);
default_drift_params.brightnesscorrect=0;
default_drift_params.roicorrect=0;
analyzetpstack_active_drift_devices('add','default_notnormed',...
	'driftcorrectbycorrelation',default_drift_params);
analyzetpstack_active_drift_devices('add','constant_shift',...
	'driftcorrectionshift',struct('warning_msg',1));
analyzetpstack_active_drift_devices('add','manual',...
	'driftcorrectionmanual',struct('instruction_msg',0));
 

TPPreviewImageFunctionListClear;
TPPreviewImageFunctionListAdd('tppreview_frameaverage','default',struct('firstFrames',1,'numFrames',30));
TPPreviewImageFunctionListAdd('tppreview_frameaverage','frame_average_500',struct('firstFrames',1,'numFrames',500));
TPPreviewImageFunctionListAdd('tppreview_frameaverage','frame_average_200',struct('firstFrames',1,'numFrames',200));
TPPreviewImageFunctionListAdd('tppreview_maxprojection','max_projection_500',struct('firstFrames',1,'numFrames',500));
TPPreviewImageFunctionListAdd('tppreview_stdprojection','std_dev_projection_500',struct('firstFrames',1,'numFrames',500));
TPPreviewImageFunctionListAdd('tppreview_stdprojection','std_dev_projection_200',struct('firstFrames',1,'numFrames',200));
TPPreviewImageFunctionListAdd('tppreview_timethreshaverage','Diff_th500_blur',struct('numFrames',100,'smoothness',5,'diffThresh',500));
TPPreviewImageFunctionListAdd('tppreview_timethreshaverage','Diff_th500_sharp',struct('numFrames',100,'smoothness',1,'diffThresh',500));
TPPreviewImageFunctionListAdd('tppreview_timethreshaverage','Diff_th20_blur',struct('numFrames',100,'smoothness',5,'diffThresh',20));
TPPreviewImageFunctionListAdd('tppreview_timethreshaverage','Diff_th20_sharp',struct('numFrames',100,'smoothness',1,'diffThresh',20));
TPPreviewImageFunctionListAdd('tppreview_timethreshaverage','Diff_th20_blur',struct('numFrames',100,'smoothness',5,'diffThresh',1));
TPPreviewImageFunctionListAdd('tppreview_timethreshaverage','Diff_th20_sharp',struct('numFrames',100,'smoothness',1,'diffThresh',1));
TPPreviewImageFunctionListAdd('tppreview_timethreshaverage','Diff_th20_blur',struct('numFrames',100,'smoothness',5,'diffThresh',.1));
TPPreviewImageFunctionListAdd('tppreview_timethreshaverage','Diff_th20_sharp',struct('numFrames',100,'smoothness',1,'diffThresh',.1));
TPPreviewImageFunctionListAdd('tppreview_rgb','choose_rgb',struct('none','none'));

TwoPhotonGlobals;
TwoPhotonColorPermute = [ 2 1 2 ];
 
