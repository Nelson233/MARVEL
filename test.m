clc;clear;
f = imread('D:\文件\学习\mRNA\应用新冠\Manuscript\投稿版\不同批次\调整后\7-1.jpg'); %读入图片（此处'1.jpg'中间为图像名称）
figure(1);imshow(f);hold on;            %显示图片
%检测并标出圆位置
%查找圆形（方括号[90 100]内为圆的半径，'Sensitivity',0.98 , 为灵敏度阈值）
[centers,radii] = imfindcircles(f,[60 70], 'Sensitivity',0.96,'Method','twostage');
h = viscircles(centers,radii);
circleParaXYR = [centers,radii];        %将检测出的圆圆心位置、半径存储进circleParaXYR矩阵
r=size(circleParaXYR,1);                %检测出的圆一共有r个
 %去除多余的圆  
 if(r > 6)                               %如果检测出的圆大于6个，就需要去除圆
  for n =r:-1:1
         if(circleParaXYR(n,1)<100||circleParaXYR(n,1)>700)  %去除圆心纵坐标在0~400以外的部分
             circleParaXYR(n,1)=[100 700];
         end
     end
end
 r=size(circleParaXYR,1);                 %重新计算检测出的圆一共有r个
 plot(circleParaXYR(:,1), circleParaXYR(:,2), 'r+');  
for k = 1:r %size(circleParaXYR, 1)  
     t=0:0.01*pi:2*pi;  
     x=cos(t).*circleParaXYR(k,3)+circleParaXYR(k,1);
     y=sin(t).*circleParaXYR(k,3)+circleParaXYR(k,2);  
    plot(x,y,'r');   end  

%检查每个圆红色和绿色分量占比
r=size(circleParaXYR,1);                 %重新计算检测出的圆一共有r个
imageSize = size(f);
croppedImage = uint8(zeros(imageSize));  %预置空图像
ImageTotal=uint8(zeros(imageSize));
Image_RTotal=uint8(zeros(imageSize));
Image_YTotal=uint8(zeros(imageSize));
for n=1:r
    c= [floor(circleParaXYR(n,2)),floor(circleParaXYR(n,1)),floor(circleParaXYR(n,3))];     % 裁剪圆的圆心位置、半径
    [xx,yy,zz] = ndgrid((1:imageSize(1))-c(1),(1:imageSize(2))-c(2),(1:imageSize(3))-c(3));
    mask = uint8((xx.^2 + yy.^2)<c(3)^2);                 %圆形掩码，把圆以外的部分的部分盖住
    croppedImage = f.*mask;
    Image=croppedImage;
    Z = uint8(zeros(imageSize));
    R=Image(:,:,1); G=Image(:,:,2); B=Image(:,:,3);       %取图像的RGB三个分量
    diff_R=0; diff_G=0; diff_B=0;  % 设置红、绿、蓝三种颜色提取阈值（越大越严格）

    %红色提取
    Image_R=Image;
    RP_R=Image(:,:,1); RP_G=Image(:,:,2); RP_B=Image(:,:,3);
    XYR=~((R-G)>diff_R &(R-B)>diff_R);  % 提取红色条件是R分量与G、B分量差值大于设定
    Mask=Z(XYR);  % 黑色背景掩膜
    RP_R(XYR)=Mask; RP_G(XYR)=Mask; RP_B(XYR)=Mask;  % 使得非红色区域变为灰色
    Image_R(:,:,1)=RP_R; Image_R(:,:,2)=RP_G; Image_R(:,:,3)=RP_B; 
    %统计红色像素点个数
    s=0;
    for x=1:imageSize(1)
        for y=1:imageSize(2)
            if XYR(x,y)==0
                s=s+1;
            end
        end
    end
    staining(n,1)=s/(3.14*circleParaXYR(n,3)^2)*100;%将红色分量占比存储入矩阵，方便后续读取显示
    
    % 绿色提取
    Image_Y=Image;
    RP_R=Image(:,:,1); RP_G=Image(:,:,2); RP_B=Image(:,:,3);
    XYR=~((G-R)>diff_G&(G-B)>diff_G);  % 提取绿色条件是G分量与R、B分量差值大于设定
    Mask=Z(XYR);  % 黑色背景掩膜
    RP_R(XYR)=Mask; RP_G(XYR)=Mask; RP_B(XYR)=Mask;  % 使得非绿色区域变为灰色
    Image_Y(:,:,1)=RP_R; Image_Y(:,:,2)=RP_G; Image_Y(:,:,3)=RP_B; 
     %统计绿色像素点个数
    s=0;
    for x=1:imageSize(1)
        for y=1:imageSize(2)
            if XYR(x,y)==0
                s=s+1;
            end
        end
    end
    staining(n,2)=s/(3.14*circleParaXYR(n,3)^2)*100;%将绿色分量占比存储入矩阵，方便后续读取显示
    ImageTotal=Image+ImageTotal;
    Image_RTotal=Image_R+Image_RTotal;
    Image_YTotal=Image_Y+Image_YTotal;
end

%% 显示结果
figure(2),imshow(f); title('12');hold on;
for n = 1 : r
    percentR = ['PR ：',num2str(staining(n,1)),'%'];
    percentY = ['PG ：',num2str(staining(n,2)),'%'];
    text(circleParaXYR(n,1),circleParaXYR(n,2)+circleParaXYR(n,3)+10,percentR,'horiz','center','color','w');
    text(circleParaXYR(n,1),circleParaXYR(n,2)+circleParaXYR(n,3)+25,percentY,'horiz','center','color','w');
end
figure(3),
subplot 211 ,imshow(Image_RTotal);
subplot 212 ,imshow(Image_YTotal);