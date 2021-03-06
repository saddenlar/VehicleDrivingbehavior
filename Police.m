function [ bool ] = Police( theta1,rho1,theta2,rho2,x,y,movement)
%Police 用于判断是否违法
%   根据左右两条车道线的方程和当前检测出的车辆位置坐标，如果越界，判定为违法

%由于检测的是图片下大半部分，所有有要弥补这个平移偏差量如下：
if y>=-(cos(theta2/180*pi)/sin(theta2/180*pi))*x+rho2/sin(theta2/180*pi)+movement&&y>=-(cos(theta1/180*pi)/sin(theta1/180*pi))*x+rho1/sin(theta1/180*pi)+movement
    bool=0;%若位于两条车道线的中间，那么就没有违法
else
    bool=1;%一旦追踪目标的坐标超越了车道线方程，判定为违法
end
end

