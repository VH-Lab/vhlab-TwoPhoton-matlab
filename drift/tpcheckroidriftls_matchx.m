function tpcheckroidriftls_matchx(tagname)
% TPCHECKROIDRIFTLS_MATCHX - Matches X axis on all windows that match tagname
%
%  tpcheckroidriftsls_matchx(tagname)
%
%  Checks the figure that was clicked on and matches the X axis for all
%  figures that share the name 'tagname'.

fig = gcbf;
ax = findobj(fig,'type','axes');
xlim = get(ax,'xlim');

z = findobj('type','figure','tag',tagname);
for i=1:length(z),
	ax = findobj(z(i),'type','axes');
	set(ax,'xlim',xlim);
end;

