%���ߣ��ܿ���

%�ó������ڼ�Ⲣ���ٳ���
%�÷�����Ŀ���ļ���Ϊ��ǰĿ¼�����г��򣬵õ��ļ�����ÿһ֡ͼ���
%�������λ���Լ����ڴ�С����position��������ʽ����[x y m n]�ֱ��Ǻ����ꡢ
%�����ꡢ���ڴ�ֱ���Ⱥʹ���ˮƽ����

%filename=dir('*.jpg');
%l=length(filename);

%------------------------------------
%��ʼ���������˲��������
%{
X=zeros(8,l);%���ڴ�ſ������˲���ÿ��Ԥ��״̬����(���Ź��Ƶ�)����ǰ���������Ĵ����ٶȺʹ�С�仯��û��X(k)=[x,y,m,n,vx,vy,dm,dn]
XX=zeros(8,l);%���ڴ�ſ������˲���ÿ�ι۲�������״̬����
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
    %title('ԭͼ�ĻҶ�ͼ');
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
    
    if i==170;%��һ�μ��Ĭ�ϴ����Ŀ�ʼ 
        [M N Z]=size(A);
        
        %x=N/2;
        %y=M/2;
        %m=floor(0.35*M);%�ݳ�
        %n=floor(0.3*N);%�᳤
        
        x=400;
        y=380;
        m=100;%�ݳ�
        n=130;%�᳤
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

    %ȡǰ���ε�ֱ�Ӽ������Ϊ���Ž⣬֮���ٴ˻����Ͽ�ʼ�������˲�Ԥ��
    %{
    if i==1
        X(:,1)=[x,y,m,n,0,0,0,0];XX(:,1)=X(:,1);
    end
    if i==2
        X(:,2)=[x,y,m,n,x-X(1,1),y-X(2,1),m-X(3,1),n-X(4,1)];
        XX(:,2)=X(:,2);
    end
    %--------------------------------------------
    %�������˲�Ԥ����һ֡����ʼ��ⴰ��λ�����С,�ڵ���֡��ʼ
    if i>=3
        %Ԥ��---------------------------------
        P2=P1+Q;
        XX(:,i)=[x,y,m,n,x-X(1,i-1),y-X(2,i-1),m-X(3,i-1),n-X(4,i-1)];%�ȼ�¼�¹۲������
        %�ش�˵�������ڼٶ���������Ƶ֡��������ֱ���˶��ģ�״̬ת�ƾ���AkΪ��λ��������X����ֱ����ΪԤ�����,������д״̬ת�Ʒ��̣�ֱ��
        %��ΪԤ����
        %-------------------------------------
        
        %����----------------------------------
        Z=Ck*XX(:,i);%�ɵ�ǰ�۲��״̬�����õ��۲�����Z��Z�е�Ԫ�ؽ�����ʵ�ʹ۲⵽�ġ�����Ҳ�����ر�
        y=Z-Ck*X(:,i-1)%����������measurement residual
        S=Ck*P2*Ck'+R;%��������Э����
        K=P2*Ck'/(S)%���ſ���������
        X(:,i)=XX(:,i)+K*y;%���µ����Ź��Ƶ�״̬����
        P1=P2-K*Ck*P2;%���µ�Э�������
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
    if abs(lines(k).theta)<60%Ŀ������������ֱ�ߺͳ����ߣ���Ϊ�������ǽ�Ϊ��ֱ��
    xy = [lines(k).point1;lines(k).point2];
    plot(xy(:,1),movement+xy(:,2),'LineWidth',2,'Color','green');

    % Plot beginnings and ends of lines
    plot(xy(1,1),movement+xy(1,2),'x','LineWidth',2,'Color','yellow');%���е�movement���ڲ�������ƫ��
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
    %B=Label(A,floor(X(1,i)),floor(X(2,i)),floor(X(3,i)),floor(X(4,i)));%������X�����ֵ��position��ʵ����Ҫ
    
    %imwrite(B,filename(i).name)%����ͼ��Ϊ�ļ�����ԭ�ļ�
end