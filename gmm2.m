clc;
clear all; 
cntFrame = 100;
obj = VideoReader('move2.avi');
numFrames = obj.NumberOfFrames;
%  for k = 1 : cntFrame
%      frame = read(obj,k);
%       imwrite(frame,...
%           strcat('D:\WTYdoc\MATLAB\graduate\video\',...
%           num2str(k),'.bmp'),'bmp');
%  end
%% 参数定义及初始化
I = imread('1.bmp');                    %读入第一帧作为背景帧
fr_bw = I;     
[height,width] = size(fr_bw);           %求每帧图像大小
width = width/3;                        %排除颜色通道数
fg = zeros(height, width);              %定义前景和背景矩阵
bg_bw = zeros(height, width);
 
C = 3;                                  % 单高斯模型的个数(通常为3-5)
M = 3;                                  % 代表背景的模型个数
D = 1;                                % 偏差阈值
alpha = 0.01;                           % 学习率
thresh = 0.25;                          % 前景阈值
sd_init = 15;                           % 初始化标准差
w = zeros(height,width,C);              % 初始化权重矩阵
mean = zeros(height,width,C);           % 像素均值
sd = zeros(height,width,C);             % 像素标准差
u_diff = zeros(height,width,C);         % 像素与某个高斯模型均值的绝对距离
p = alpha/(1/C);                        % 初始化p变量，用来更新均值和标准差
rank = zeros(1,C);                      % 各个高斯分布的优先级（w/sd)
 
pixel_depth = 8;                        % 每个像素8bit分辨率
pixel_range = 2^pixel_depth -1;         % 像素值范围[0,255]
 
for i=1:height
    for j=1:width
        for k=1:C
            mean(i,j,k) = rand*pixel_range;     %初始化第k个高斯分布的均值
            w(i,j,k) = 1/C;                     % 初始化第k个高斯分布的权重
            sd(i,j,k) = sd_init;                % 初始化第k个高斯分布的标准差           
        end
    end
end
 
for n = 1:3:cntFrame
    frame=strcat(num2str(n),'.bmp');
    I1 = imread(frame);  % 依次读入各帧图像
    fr_bw = I1;       
    % 计算新像素与第m个高斯模型均值的绝对距离
    for m=1:C
        u_diff(:,:,m) = abs(double(fr_bw(:,:,m)) - double(mean(:,:,m)));
    end
    % 更新高斯模型的参数
    for i=1:height
        for j=1:width
            match = 0;                                       %匹配标记;
            for k=1:C                       
                if (abs(u_diff(i,j,k)) <= D*sd(i,j,k))       % 像素与第k个高斯模型匹配  
                    match = 1;                               %将匹配标记置为1
                    % 更新权重、均值、标准差、p
                    w(i,j,k) = (1-alpha)*w(i,j,k) + alpha;
                    p = alpha/w(i,j,k);                  
                    mean(i,j,k) = (1-p)*mean(i,j,k) + p*double(fr_bw(i,j));
                    sd(i,j,k) =   sqrt((1-p)*(sd(i,j,k)^2) + p*((double(fr_bw(i,j)) - mean(i,j,k)))^2);
                else                                         % 像素与第k个高斯模型不匹配
                    w(i,j,k) = (1-alpha)*w(i,j,k);           %略微减少权重   
                end
            end      
            bg_bw(i,j)=0;
            for k=1:C
                bg_bw(i,j) = bg_bw(i,j)+ mean(i,j,k)*w(i,j,k);
            end
            % 像素值与任一高斯模型都不匹配，则创建新的模型
            if (match == 0)
                [min_w, min_w_index] = min(w(i,j,:));      %寻找最小权重
                mean(i,j,min_w_index) = double(fr_bw(i,j));%初始化均值为当前观测像素的均值
                sd(i,j,min_w_index) = sd_init;             %初始化标准差为6
            end
            rank = w(i,j,:)./sd(i,j,:);                    % 计算模型优先级
            rank_ind = (1:1:C);%优先级索引       
            % 计算前景      
            fg(i,j) = 0;
            while ((match == 0)&&(k<=M))         
                    if (abs(u_diff(i,j,rank_ind(k))) <= D*sd(i,j,rank_ind(k)))% 像素与第k个高斯模型匹配
                        fg(i,j) = 0; %该像素为背景，置为黑色        
                    else
                        fg(i,j) = 255;    %否则为前景，置为白色 
                    end                        
                k = k+1;
            end
        end
    end
    
    T=graythresh(fg);
    fg_bw=im2bw(fg,T);
    erodeElement = strel('square',1) ;
    dilateElement=strel('square',4) ;
    fg_bw=imerode(fg_bw,erodeElement);
    fg_bw=imdilate(fg_bw,dilateElement);
    fg_bw=imfill(fg_bw,'holes');
    fg_reg=regionprops(fg_bw,'area','boundingbox');
    areas=[fg_reg.Area];
    rects=cat(1,fg_reg.BoundingBox);
    
    figure(n)
    subplot(1,3,1),imshow(fr_bw);               %显示最后一帧图像
    for i=1:size(rects,1)
        if(rects(i,3)>50&&rects(i,4)>60)
            rectangle('position',rects(i,:),'EdgeColor','r');
        end
    end
    subplot(1,3,2),imshow(uint8(bg_bw))         %显示背景
    subplot(1,3,3),imshow(fg_bw);   %显示前景
end