function cm=fluoview_colormaps(c)
%FLUOVIEW_COLORMAPS creates RGB colormaps (red: c=1, green: c=2, blue: c=3) for Olympus
%Fluoview Multitiff or other images
%
%CM=FLUOVIEW_COLORMAPS ( C ) 
%
%2008, Danielle van Versendaal 


cm(64,3)=0;

cm(:,c)=linspace(0.015,0.984,64)';


% cm(64,3)=0;
% j=1/((length(cm))-1);
% for i=1:64
% 	cm(i,c)=1-(j*(i-1));
% end