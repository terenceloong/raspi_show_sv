% clear;
clc;

% if exist('mycam', 'var')
%     clearvars mycam
% end

% mypi = raspi
% mycam = cameraboard(mypi,'Resolution','800x600');
% mycam.Rotation = 180

for k = 1:100
%     disp(k);
    
    img = snapshot(mycam);
    imagesc(img); % imshow(img); slow
%     hold on
%     plot(400,400, 'Marker','o', 'MarkerEdgeColor','y', 'MarkerFaceColor','y', 'MarkerSize',12);
%     hold off
    drawnow
end

% clearvars mycam