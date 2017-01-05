function tphotonnoiseanalysis(filename, line_num,line_list);

 % line_num = 367 for mouse-2014-07-11-t00002-001.tif
 % line_num = 112 for testpollen.tif


lines = [];
for i=1:675,
    tf=imread(filename,i); lines(i,:) = tf(line_num,:);
end;

figure;
image(lines);
colormap(gray(2048));

figure;
plot(lines(:,line_list(1)),'b')
hold on
plot(lines(:,line_list(2)),'r')

mn = {};
dev = {};

for i=1:length(line_list),
    mn{i} = mean(lines(:,line_list(i)));
    dev{i} = lines(:,line_list(i)) - mn{i};
end;


[slope,offset,conf_interval]=quickregression(dev{2},dev{3},0.05);


linesmn = mean(lines);

linesdev = lines - repmat(linesmn,size(lines,1),1);

keyboard;