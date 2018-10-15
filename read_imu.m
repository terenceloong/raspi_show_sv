% clear;
clc;

if exist('myserialdevice', 'var')
    clearvars myserialdevice
end

% mypi = raspi %Create connection to Raspberry Pi hardware
myserialdevice = serialdev(mypi,'/dev/ttyAMA0') %Create connection to serial device

f = 20; %Hz, imu data rate
dn = 440; %number of Bytes read once from serial
t = 20; %s, run time
remain = [];
imu = ones(t*f*2,9)*NaN;
p = 1;

for k=1:ceil(t*f/(dn/44))
%     disp(k*dn/44/f);
    fprintf('%.1f\n', k*dn/44/f);
    output = read(myserialdevice, dn);
    stream = [remain, output];
    ki = 1;
    ni = length(stream);
    while 1
        if stream(ki)==85
            if stream(ki+1)==81 %acc
                if ~(isnan(imu(p,1)) && isnan(imu(p,4)) && isnan(imu(p,7)))
                    p = p+1;
                end
                imu(p,1) = double(typecast(stream(ki+(2:3)),'int16')) /32768*4;
                imu(p,2) = double(typecast(stream(ki+(4:5)),'int16')) /32768*4;
                imu(p,3) = double(typecast(stream(ki+(6:7)),'int16')) /32768*4;
                ki = ki+11;
            elseif stream(ki+1)==82 %gyro
                if ~(isnan(imu(p,4)) && isnan(imu(p,7)))
                    p = p+1;
                end
                imu(p,4) = double(typecast(stream(ki+(2:3)),'int16')) /32768*500;
                imu(p,5) = double(typecast(stream(ki+(4:5)),'int16')) /32768*500;
                imu(p,6) = double(typecast(stream(ki+(6:7)),'int16')) /32768*500;
                ki = ki+11;
            elseif stream(ki+1)==84 %mag
                if ~isnan(imu(p,7))
                    p = p+1;
                end
                imu(p,7) = double(typecast(stream(ki+(2:3)),'int16'));
                imu(p,8) = double(typecast(stream(ki+(4:5)),'int16'));
                imu(p,9) = double(typecast(stream(ki+(6:7)),'int16'));
                p = p+1;
                ki = ki+11;
            else
                ki = ki+11;
            end
        else
            ki = ki+1;
        end
        %--break--%
        if ki+10>ni
            remain = stream(ki:end);
            break;
        end
    end
    %------Attitude-------------------------------------------------------%
    acc = [imu(p-1,3),-imu(p-1,2),imu(p-1,1)] - [-0.088, 0, 0.013];
    mag = [imu(p-1,9),-imu(p-1,8),imu(p-1,7)] - [-3.315727732599372, 68.030979957174310, -46.183376277053846];
    mag = (diag([0.007276026602769,0.007404587271340,0.007211230896854])*mag')';
    mag = mag/norm(mag);
    theta = asin(acc(1)/norm(acc));
    gamma = atan2(-acc(2), -acc(3));
    psi = atan2(mag(3)*sin(gamma)-mag(2)*cos(gamma), mag(1)*cos(theta)+(mag(3)*cos(gamma)+mag(2)*sin(gamma))*sin(theta));
    psi = mod(psi/pi*180-10, 360);
    theta = theta/pi*180;
    gamma = gamma/pi*180;
    fprintf('%.1f   ', psi);
    fprintf('%.1f   ', theta);
    fprintf('%.1f   ', gamma);
    fprintf('\n');
    %---------------------------------------------------------------------%
end

% clearvars mypi myserialdevice
clearvars myserialdevice

imu(p:end,:) = [];
imu = [imu(:,6),-imu(:,5),imu(:,4), imu(:,3),-imu(:,2),imu(:,1), imu(:,9),-imu(:,8),imu(:,7)];