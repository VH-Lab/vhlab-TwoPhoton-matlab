function analyzetpstack_correctdriftall(fignum, channel)

ud = get(fignum,'userdata');

ds = dirstruct(getpathname(ud.ds));

answ= {'[-6:2:6]','[-6:2:6]','[-100:10:100]','[-100:10:100]','10','5','1','1','0'};
searchx = eval(answ{1}); searchy = eval(answ{2}); refsearchx = eval(answ{3}); refsearchy = eval(answ{4});
howoften = eval(answ{5}); howmany = eval(answ{6});
brightnesscorrect = eval(answ{7}); roicorrect = eval(answ{8});
onlylocal = eval(answ{9});

t = {ud.slicelist(:).dirname};

for i=1:length(t), t{i} = trimws(t{i}); end;


for i=1:length(t),
	dirname = t{i};
	disp(['Now correcting ' dirname '.']);
	refdirname = analyzetpstack_getrefdirname(ud,dirname),
	fulldirname = [fixpath(getpathname(ud.ds)) dirname];
	fullrefdirname = [fixpath(getpathname(ud.ds)) refdirname];
	if onlylocal, myfullrefdirname = fulldirname; else, myfullrefdirname = fullrefdirname; end;
	dr=tpdriftcheck(fulldirname,channel,searchx,searchy,myfullrefdirname,...
		refsearchx,refsearchy,howoften,howmany,brightnesscorrect,roicorrect,1,1);
	if ~isempty(dr),
		TwoPhotonGlobals;
		dr_dists = sqrt(sum((dr - repmat(mean(dr),size(dr,1),1).^2),2));
		mx = max(dr_dists);
		if mx>TwoPhotonDriftWarn,
			warning(['-----LOCAL DRIFT EXCEEDS DRIFT WARNING SIZE: directory ' fulldirname ', drift warn limit is ' num2str(TwoPhotonDriftWarn) ', max drift was ' num2str(mx) '.']);
		end;
	end;
	
end;

