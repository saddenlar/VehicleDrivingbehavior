%作者：熊俊峰

%该程序用于检测并跟踪车辆
%用法：打开目标文件夹为当前目录，运行程序，得到文件夹中每一帧图像的
%车辆检测位置以及窗口大小，以position向量的形式返回[x y m n]分别是横坐标、
%纵坐标、窗口垂直长度和窗口水平长度

%filename=dir('*.jpg');
%l=length(filename);

%------------------------------------
%初始化卡尔曼滤波所需变量
%{
X=zeros(8,l);%用于存放卡尔曼滤波的每次预测状态向量(最优估计的)，但前两个向量的窗口速度和大小变化率没有X(k)=[x,y,m,n,vx,vy,dm,dn]
XX=zeros(8,l);%用于存放卡尔曼滤波的每次观测下来的状态向量
P1=eye(8);
Q=eye(8);
R=eye(8);
Ak=eye(8);
Ck=eye(8);
%}
%------------------------------------

for i=170:329
    savefile=['picture_',num2str(i),'.jpg'];%['image_0001.jpg'];
    A=imread(savefile);
    %{
    I=rgb2gray(A);
    %figure;imshow(I);
    [M0 N0]=size(I);
    %I=histeq(I);
    movement=M0/3;
    I=I(movement:end,:);
    %figure;imshow(I);
    %title('原图的灰度图');
    BW=edge(I,'sobel',0.09);
    %figure;imshow(BW);
    [H,T,R] = hough(BW);
    %figure;imshow(H,[],'XData',T,'YData',R,...
    %            'InitialMagnification','fit');
    %xlabel('\theta'), ylabel('\rho');
    %axis on, axis normal, hold on;
    P  = houghpeaks(H,10,'threshold',ceil(0.3*max(H(:))));%
    %x = T(P(:,2)); y = R(P(:,1));
    %plot(x,y,'s','color','white');
    % Find lines and plot them
    lines = houghlines(BW,T,R,P);%,'FillGap',5,'MinLength',7
    %}
    
    if i==170;%第一次检测默认从中心开始 
        [M N Z]=size(A);
        
        %x=N/2;
        %y=M/2;
        %m=floor(0.35*M);%纵长
        %n=floor(0.3*N);%横长
        
        x=400;
        y=380;
        m=100;%纵长
        n=130;%横长
        counter=0;
    end
    if mod(i,12)==0
        counter=0;
    else
        counter=5;
    end
    [ x y m n counter] = Findcar( A,x,y,m,n,counter );
    %x=floor(x);
    %y=floor(y);

    %取前两次的直接检测结果作为最优解，之后再此基础上开始卡尔曼滤波预测
    %{
    if i==1
        X(:,1)=[x,y,m,n,0,0,0,0];XX(:,1)=X(:,1);
    end
    if i==2
        X(:,2)=[x,y,m,n,x-X(1,1),y-X(2,1),m-X(3,1),n-X(4,1)];
        XX(:,2)=X(:,2);
    end
    %--------------------------------------------
    %卡尔曼滤波预测下一帧的起始检测窗口位置与大小,在第三帧开始
    if i>=3
        %预测---------------------------------
        P2=P1+Q;
        XX(:,i)=[x,y,m,n,x-X(1,i-1),y-X(2,i-1),m-X(3,i-1),n-X(4,i-1)];%先记录下观测的向量
        %特此说明：由于假定车辆在视频帧中是匀速直线运动的，状态转移矩阵Ak为单位矩阵，所以X矩阵直接作为预测矩阵,而不用写状态转移方程，直接
        %作为预测结果
        %-------------------------------------
        
        %更新----------------------------------
        Z=Ck*XX(:,i);%由当前观测的状态向量得到观测向量Z，Z中的元素叫做‘实际观测到的’，我也不是特别懂
        y=Z-Ck*X(:,i-1)%测量余量，measurement residual
        S=Ck*P2*Ck'+R;%测量余量协方差
        K=P2*Ck'/(S)%最优卡尔曼增益
        X(:,i)=XX(:,i)+K*y;%更新的最优估计的状态向量
        P1=P2-K*Ck*P2;%更新的协方差估计
        %---------------------------------------
        x=X(1,i);
        y=X(2,i);
        m=X(3,i);
        n=X(4,i);
    %--------------------------------------------
    end
    %}
    i
    B=Label(A,x,y,m,n);
    h=figure;imshow(B);hold on
    %{
    for k = 1:length(lines)
    if abs(lines(k).theta)<60%目的是区分其他直线和车道线，因为车道线是较为竖直的
    xy = [lines(k).point1;lines(k).point2];
    plot(xy(:,1),movement+xy(:,2),'LineWidth',2,'Color','green');

    % Plot beginnings and ends of lines
    plot(xy(1,1),movement+xy(1,2),'x','LineWidth',2,'Color','yellow');%其中的movement用于补偿坐标偏移
    plot(xy(2,1),movement+xy(2,2),'x','LineWidth',2,'Color','red');

    % Determine the endpoints of the longest line segment
    len = norm(lines(k).point1 - lines(k).point2);
    
    end
    end
    %}
    hold off
    newsavefile=['newpicture_',num2str(i),'.jpg'];
    saveas(h,newsavefile,'jpg');
    close(figure(gcf));
    %B=Label(A,floor(X(1,i)),floor(X(2,i)),floor(X(3,i)),floor(X(4,i)));%可以用X里面的值，position其实不需要
    
    %imwrite(B,filename(i).name)%保存图像为文件覆盖原文件
end