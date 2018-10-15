clear;
clc;

p = [45+44/60+27.4955/3600, 126+37/60+39.4257/3600, 166]; %location

c = clock; %current time
[filename, gps_week, gps_second] = download_almanac(c);
gps_almanac = read_gps_almanac(filename);
data = sv_azi_ele(gps_almanac, gps_week, gps_second, p);
index = data(:,3)<5; %elevation angle threshold
data(index,:) = [];
data(:,2) = mod(data(:,2),360);

data_p = data;
data_p(:,2) = mod(data_p(:,2)-90,360)/180*pi;

% figure
polarscatter(data_p(:,2),data_p(:,3), 220, 'MarkerEdgeColor','g', 'MarkerFaceColor','y');
ax = gca;
ax.RLim = [0 90];
ax.RDir = 'reverse';
ax.ThetaDir = 'clockwise';
ax.RTick = [0 15 30 45 60 75 90];
ax.ThetaTickLabel = {'90','120','150','180','210','240','270','300','330','0','30','60'};

for k=1:size(data,1)
    text(data_p(k,2),data_p(k,3),num2str(data(k,1)), 'HorizontalAlignment','center', 'VerticalAlignment','middle');
end

title(['UTC: ',num2str(c(1)),'-',num2str(c(2)),'-',num2str(c(3)),' ',...
    sprintf('%02d',c(4)),':',sprintf('%02d',c(5)),':',sprintf('%02d',floor(c(6)))]);