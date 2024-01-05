clc;clear;
f = imread('D:\Document\variant-beta.jpg'); %In put your image（'1.jpg' is the name of your image）
figure(1);imshow(f);hold on;            %Present the image
%Circle localization and segmentation（[90 100]is the radius of circle ，'Sensitivity',0.98 , is the sensitivity）
[centers,radii] = imfindcircles(f,[60 70], 'Sensitivity',0.96,'Method','twostage');
h = viscircles(centers,radii);
circleParaXYR = [centers,radii];      
r=size(circleParaXYR,1);             
 
 if(r > 6)    % It is up to the circles you desined in the origami papers
  for n =r:-1:1
         if(circleParaXYR(n,1)<100||circleParaXYR(n,1)>700) 
             circleParaXYR(n,1)=[100 700];
         end
     end
end
 r=size(circleParaXYR,1);               
 plot(circleParaXYR(:,1), circleParaXYR(:,2), 'r+');  
for k = 1:r %size(circleParaXYR, 1)  
     t=0:0.01*pi:2*pi;  
     x=cos(t).*circleParaXYR(k,3)+circleParaXYR(k,1);
     y=sin(t).*circleParaXYR(k,3)+circleParaXYR(k,2);  
    plot(x,y,'r');   end  

r=size(circleParaXYR,1);              
imageSize = size(f);
croppedImage = uint8(zeros(imageSize)); 
ImageTotal=uint8(zeros(imageSize));
Image_RTotal=uint8(zeros(imageSize));
Image_YTotal=uint8(zeros(imageSize));
for n=1:r
    c= [floor(circleParaXYR(n,2)),floor(circleParaXYR(n,1)),floor(circleParaXYR(n,3))];    
    [xx,yy,zz] = ndgrid((1:imageSize(1))-c(1),(1:imageSize(2))-c(2),(1:imageSize(3))-c(3));
    mask = uint8((xx.^2 + yy.^2)<c(3)^2);                
    croppedImage = f.*mask;
    Image=croppedImage;
    Z = uint8(zeros(imageSize));
    R=Image(:,:,1); G=Image(:,:,2); B=Image(:,:,3);      
    diff_R=0; diff_G=0; diff_B=0;  

    %Extract R components
    Image_R=Image;
    RP_R=Image(:,:,1); RP_G=Image(:,:,2); RP_B=Image(:,:,3);
    XYR=~((R-G)>diff_R &(R-B)>diff_R);  
    Mask=Z(XYR); 
    RP_R(XYR)=Mask; RP_G(XYR)=Mask; RP_B(XYR)=Mask; 
    Image_R(:,:,1)=RP_R; Image_R(:,:,2)=RP_G; Image_R(:,:,3)=RP_B; 
    s=0;
    for x=1:imageSize(1)
        for y=1:imageSize(2)
            if XYR(x,y)==0
                s=s+1;
            end
        end
    end
    staining(n,1)=s/(3.14*circleParaXYR(n,3)^2)*100;
    
    % Extract G components
    Image_Y=Image;
    RP_R=Image(:,:,1); RP_G=Image(:,:,2); RP_B=Image(:,:,3);
    XYR=~((G-R)>diff_G&(G-B)>diff_G); 
    Mask=Z(XYR);
    RP_R(XYR)=Mask; RP_G(XYR)=Mask; RP_B(XYR)=Mask; 
    Image_Y(:,:,1)=RP_R; Image_Y(:,:,2)=RP_G; Image_Y(:,:,3)=RP_B; 
    s=0;
    for x=1:imageSize(1)
        for y=1:imageSize(2)
            if XYR(x,y)==0
                s=s+1;
            end
        end
    end
    staining(n,2)=s/(3.14*circleParaXYR(n,3)^2)*100;
    ImageTotal=Image+ImageTotal;
    Image_RTotal=Image_R+Image_RTotal;
    Image_YTotal=Image_Y+Image_YTotal;
end

%% Output the proportion the  G components
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
