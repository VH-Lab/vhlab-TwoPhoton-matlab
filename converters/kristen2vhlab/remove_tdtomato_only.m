function remove_tdtomato_only(fignum)
% REMOVE_TDTOMATO_ONLY - Removes tdTomato only from analyzetpstack
%
%   REMOVE_TDTOMATO_ONLY(FIGNUM)
%

ud = get(fignum,'userdata');

v = 1;

while v<length(ud.celllist),
	if eqlen(ud.celllist(v).labels,{'tdTomato'}),
		set(findobj(fignum,'tag','celllist'),'value',v);
		analyzetpstack('deletecellBt',[],fignum);
		ud = get(fignum,'userdata');
	else,
		v = v+1;
	end;
end;
