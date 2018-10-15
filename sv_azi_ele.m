function data = sv_azi_ele(almanac, gps_week, gps_second, p)
%data = [ID, azimuth, elevation angle]

num = size(almanac,1);
data = zeros(num,3);
data(:,1) = almanac(:,1); %ID
toe = almanac(1,8);
t = (gps_week-almanac(1,12))*604800 + (gps_second-toe); %s
miu = 3.986005e14;
w = 7.2921151467e-5;

Cen = dcmecef2ned(p(1), p(2));
rp = lla2ecef([p(1), p(2), p(3)])'; %(ecef)

for k=1:num
    a = almanac(k,2);
    n = sqrt(miu/a^3); %mean motion
    M = mod(almanac(k,7)+n*t, 2*pi); %0-2*pi
    e = almanac(k,3);
    E = kepler(M, e); %0-2*pi
    f = 2*mod(atan(sqrt((1+e)/(1-e))*tan(E/2)), pi); %0-2*pi
    phi = f+almanac(k,6);
    i = almanac(k,4);
    Omega = almanac(k,5) + (almanac(k,9)-w)*t - w*toe;
    
    r = a*(1-e*cos(E));
    x = r*cos(phi);
    y = r*sin(phi);
    rs = [x*cos(Omega)-y*cos(i)*sin(Omega); x*sin(Omega)+y*cos(i)*cos(Omega); y*sin(i)]; %(ecef)
    
    rps = rs-rp; %the vector from p to sv (ecef)
    rpsu = rps/norm(rps); %unit vector (ecef)
    rpsu_n = Cen*rpsu; %(ned)
    
    data(k,2) = atan2d(rpsu_n(2),rpsu_n(1)); %azimuth, deg
    data(k,3) = asind(-rpsu_n(3)); %elevation angle, deg
end

end

function E = kepler(M, e)
    E = M;
    Ei = E - (E-e*sin(E)-M)/(1-e*cos(E));
    while abs(Ei-E) > 1e-10
        E = Ei;
        Ei = E - (E-e*sin(E)-M)/(1-e*cos(E));
    end
end