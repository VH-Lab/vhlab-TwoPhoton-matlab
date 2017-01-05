function TwoPhoton_Photodiode_SGS(dirname, sitename, photooff)

 % recently measured offset between rise time of photodiode potential and spike detection on spike2: -2e-4
 % that is, spike detection proceeds photodiode potential rise

 photodiodeoffset = -2e-4;

 tp_offset = 3.488-3.333;

[path,thedirname] = fileparts(dirname);

try,
	tp = load([dirname filesep sitename '_' thedirname '_raw.mat']);
catch,
	disp(['No analyzed twophoton data found']); 
	tp.data = {}; tp.t = {};
end;

stims = load([dirname filesep 'stims.mat']);

[mti,starttime] = tpcorrectmti(stims.MTI2,[dirname filesep 'stimtimes.txt'],0);

try,
	spiketimes = load([dirname filesep 'spiketimes_0_000.txt'],'-ascii');
	spiketimes = spiketimes(find(spiketimes<0));
catch,
	disp(['No spiketimes found or there was an error reading them.']);
	spiketimes = [];
end;

stimontimes = load([dirname filesep 'stimontimes.txt'],'-ascii');
stimontimes = stimontimes(2:2:end);

vrt = load([dirname filesep 'verticalblanking.txt'],'-ascii');
vrt = vrt(find(vrt<50));

mm = load([dirname filesep 'myspikedata2.mat'],'-mat');

ft = load([dirname filesep 'frametrigger.txt'],'-ascii');

spike_t = 3e-5+(0:6e-5:(length(mm.spike2data_Ch1.values)-1)*(6e-5));

inds2plot = find(spike_t<100);
values = mm.spike2data_Ch1.values;
values = values(inds2plot);

clear mm;

 % first figure, just plot the whole business

time_offset = 0.0730*0;

b = [0];
t = [0];

for i=1:length(mti),
	sgs = get(stims.saveScript,i);
	% which stim is white?
	p = getparameters(sgs);
	whitevalue = 0;
	for j=1:size(p.values,1)
		if eqlen(p.values(j,:),[255 255 255]),
			whitevalue = j;
		end;
	end;
	v = getgridvalues(sgs);
	for f = 1:length(mti{i}.frameTimes),
		b(end+1) = b(end);
		t(end+1) = mti{i}.frameTimes(f)-starttime+time_offset;
		b(end+1) = double(v(f)==whitevalue);
		t(end+1) = mti{i}.frameTimes(f)-starttime+time_offset;
	end
	t(end+1) = mti{i}.startStopTimes(3)-starttime+time_offset;
	b(end+1) = b(end);
	t(end+1) = mti{i}.startStopTimes(3)-starttime+time_offset;
	b(end+1) = 0;
end;

figure;

plot(t,b,'k');

hold on;

for i=1:length(spiketimes),
	plot(spiketimes(i)*[1 1],[1.02 1.03],'b-');
end;

for i=1:length(vrt),
	plot(vrt(i)*[1 1],[1.04 1.08],'g-');
end;
for i=1:length(ft),
	plot(ft(i)*[1 1],[1.00 1.01],'k-');
end;

plot(spike_t(inds2plot),rescale(values,[min(values) max(values)],[0 1]),'m');

plot(tp.t{1}+tp_offset,rescale(tp.data{1},[min(tp.data{1}(:)) max(tp.data{1}(:))],[0 1]),'ro');

box off;

keyboard;
