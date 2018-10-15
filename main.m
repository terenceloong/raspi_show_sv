% https://blog.csdn.net/u010186001/article/details/73335385

%%
global flag
flag = 0;
load intrinsic.mat

%%
p = [45+44/60+27.4955/3600, 126+37/60+39.4257/3600, 166]; %location
[filename, gps_week, gps_second] = download_almanac(clock);
gps_almanac = read_gps_almanac(filename);

%%
psi = 0;
theta = 0;
gamma = 0;
acc = [0,0,0];
mag = [0,0,0];
stream = [];

%%
if exist('mycam', 'var')
    clearvars mycam
end
mycam = cameraboard(mypi,'Resolution','800x600');
mycam.Rotation = 180

f = figure;
set(f,'WindowKeyReleaseFcn', @keyreleasefcn);

%%
if exist('myserialdevice', 'var')
    clearvars myserialdevice
end
myserialdevice = serialdev(mypi,'/dev/ttyAMA0');
myserialdevice.Timeout = 0

%%
while 1
    if flag==1
        clearvars mycam myserialdevice
        break;
    end
    
    while 1
        output = read(myserialdevice, 44);
        if isempty(output)
            break;
        else
            stream = [stream, output];
        end
    end
    if length(stream)>=88
        data = stream(end-87:end);
        for k=1:45
            if data(k)==85 && data(k+1)==81
                if data(k+12)==82 && data(k+23)==84
                    acc(1) =  double(typecast(data(k+(6:7)),'int16')) /32768*4;
                    acc(2) = -double(typecast(data(k+(4:5)),'int16')) /32768*4;
                    acc(3) =  double(typecast(data(k+(2:3)),'int16')) /32768*4;
                    mag(1) =  double(typecast(data(k+(28:29)),'int16'));
                    mag(2) = -double(typecast(data(k+(26:27)),'int16'));
                    mag(3) =  double(typecast(data(k+(24:25)),'int16'));
                    acc = acc - [-0.088, 0, 0.013];
                    mag = mag - [-3.315727732599372, 68.030979957174310, -46.183376277053846];
                    mag = (diag([0.007276026602769,0.007404587271340,0.007211230896854])*mag')';
                    mag = mag/norm(mag);
                    theta = asin(acc(1)/norm(acc));
                    gamma = atan2(-acc(2), -acc(3));
                    psi = atan2(mag(3)*sin(gamma)-mag(2)*cos(gamma), mag(1)*cos(theta)+(mag(3)*cos(gamma)+mag(2)*sin(gamma))*sin(theta));
                    psi = mod(psi/pi*180-10, 360);
                    theta = theta/pi*180;
                    gamma = gamma/pi*180;
                end
            end
        end
        stream = [];
    end
    
    img = snapshot(mycam);
    imagesc(img);
    title(['\psi=',sprintf('%.1f',psi),'\circ, \theta=',sprintf('%.1f',theta),'\circ, \gamma=',sprintf('%.1f',gamma),'\circ']);
    %---------------------------------------------------------------------%
    hold on
    [gps_week, gps_second] = gps_time(clock);
    sv = sv_azi_ele(gps_almanac, gps_week, gps_second, p);
    index = sv(:,3)<5; %elevation angle threshold
    sv(index,:) = [];
    sv(:,2) = mod(sv(:,2),360);
    for k=1:size(sv,1)
        rn = [cosd(sv(k,2)); sind(sv(k,2)); -sind(sv(k,3))];
        Cnb = angle2dcm(psi/180*pi, theta/180*pi, gamma/180*pi);
        rb = Cnb*rn;
        if acosd(rb(1))<80
            x = rb(2)/rb(1);
            y = rb(3)/rb(1);
            pos = [x,y,1]*intrinsic;
            if pos(1)>=1 &&pos(1)<=800 && pos(2)>=1 && pos(2)<=600
                plot(pos(1),pos(2), 'Color','r', 'Marker','o', 'MarkerSize',20, 'MarkerEdgeColor','g', 'MarkerFaceColor','y');
                text(pos(1),pos(2),num2str(sv(k,1)), 'HorizontalAlignment','center', 'VerticalAlignment','middle');
            end
        end
    end
    hold off
    %---------------------------------------------------------------------%
    drawnow
end

%%
function keyreleasefcn(~, event)
    global flag
    if event.Character=='q'
        flag = 1;
    end
end