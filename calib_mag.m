%%
D0 = imu(:,7:9);
n = size(D0,1);

figure
plot3(D0(:,1), D0(:,2), D0(:,3))
axis equal

%%
[c, S, lamda] = mag_calib_fun(D0(:,1), D0(:,2), D0(:,3));
disp('c:');
disp(c');
disp('lamda:');
disp(lamda');

%%
vl = zeros(n,1);
for k=1:n
    D0(k,:) = (S*(D0(k,:)'-c))';
    vl(k) = norm(D0(k,:));
end
figure
plot(vl)

figure
plot3(D0(:,1), D0(:,2), D0(:,3))
axis equal

figure
[x,y,z] = sphere;
h = surf(x,y,z, 'FaceAlpha',0.5);
h.EdgeColor = 'none';
axis equal
hold on
plot3(D0(:,1), D0(:,2), D0(:,3), 'LineWidth',2)
quiver3(0,0,0, 1,0,0, 'Color','b', 'LineWidth',3)
quiver3(0,0,0, 0,1,0, 'Color','m', 'LineWidth',3)
quiver3(0,0,0, 0,0,1, 'Color','r', 'LineWidth',3)

%%
function [c, S, lamda] = mag_calib_fun(x, y, z)
    H = [x.^2, y.^2, z.^2, x, y, z];
    a = (H'*H)\H'*ones(length(x),1);
    Q = diag(a(1:3));
    c = (-0.5*a(4:6)'/Q)';
    M = Q/(1+c'*Q*c);
    S = sqrt(M);
    lamda = 1./diag(S);
end