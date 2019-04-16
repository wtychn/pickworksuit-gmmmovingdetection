clc
close all
clear
RGB=imread('testpeo.jpg');
RGB1=imcrop(RGB,[1500,500,2200,2200]);
BW=im2bw(RGB1,0.3);
tohandle=~BW;
subplot(2,2,1);
imshow(RGB);
title('原图');
subplot(2,2,2);
imshow(RGB1);
title('裁剪');
subplot(2,2,3);
imshow(BW);
title('二值化');

%进行形态学处理：腐蚀、膨胀、孔洞填充
erodeElement = strel('square', 3) ;
dilateElement=strel('square', 8) ;
tohandle=imerode(tohandle,erodeElement);
tohandle=imerode(tohandle,erodeElement);
tohandle=imdilate(tohandle,dilateElement);
tohandle=imdilate(tohandle,dilateElement);
tohandle=imfill(tohandle,'holes');
subplot(2,2,4);
imshow(tohandle);
title('颜色反转与形态学处理');

%获取区域的'basic'属性， 'Area', 'Centroid', and 'BoundingBox' 
figure('name','处理结果'),
stats = regionprops(tohandle, 'basic');
rects=cat(1,stats.BoundingBox);
f_areas=find([stats.Area]>80000);
f_rects=rects(f_areas, :);
%定位脸部区域
imshow(RGB1);
hold on
for i = 1:size(f_rects, 1)
    rectangle('Position',f_rects(i,:),'LineWidth',2,'LineStyle','--','EdgeColor','r'),
end
hold off