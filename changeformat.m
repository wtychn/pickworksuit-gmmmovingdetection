clc
close all
clear
RGB=imread('testimg.jpg');
X=rgb2gray(RGB);
imwrite(X,'testgray.jpg','JPG');
subplot(2,2,1),
subimage(RGB);
title('ԭʼͼ��');
subplot(2,2,2),
subimage(X);
title('�Ҷ�ͼ��');
X2=im2bw(X,0.6);
imwrite(X2,'testbw.png','PNG');
subplot(2,2,3),
subimage(X2);
title('��ֵͼ��');
Y=grayslice(X,8);
imwrite(Y,'testind.tif','TIFF');
subplot(2,2,4);
subimage(Y,jet(8));
title('����ͼ��');