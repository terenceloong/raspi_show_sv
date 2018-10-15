if ~exist('h','var')
    h = 0;
end

h = h+1;
eval(['img',num2str(h),' = snapshot(mycam);'])
eval(['p',num2str(h),' = rgb2gray(img',num2str(h),');'])
figure
eval(['imshow(p',num2str(h),')'])
eval(['imwrite(p',num2str(h),',''./image/p',num2str(h),'.bmp'');'])