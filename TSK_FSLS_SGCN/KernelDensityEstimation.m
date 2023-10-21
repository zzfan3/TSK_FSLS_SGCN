% Kernel Density Estimation
% 只能处理正半轴密度
function [t, y_true, tt, y_KDE] = KernelDensityEstimation(x)
% clear

% x = px_last;
% x = px_last_tu;
%%
%参数初始化
Max = round(max(x));           %数据中最大值
Min = round(min(x));           %数据中最小值
Ntotal = length(x);     %数据个数
tt = 0 : 0.01 : Max;     %精确x轴

t = 0 : Max;            %粗略x轴

y_KDE = zeros(100 * Max+1, 1);   %核密度估计值
sum1 = 0;                       %求和的中间变量
%%
%计算带宽h
R = 1/(2*sqrt(pi));
m2 = 1;
h = 3;
% h = (R)^(1/5) / (m2^(2/5) * R^(1/5) * Ntotal^(1/5));

%%
%计算核密度估计
for i = 0 : 0.01 : Max        
    for j = 1 : Ntotal
        sum1 = sum1 + normpdf(i-x(j));
    end
    y_KDE(round(i*100+1)) = sum1 / (h * Ntotal);
    sum1 = 0;
end

sum2 = sum(y_KDE)*0.01;  %归一化KDE密度
for i = 0 : 0.01 : Max
    y_KDE(round(i*100+1)) = y_KDE(round(i*100+1))/sum2;
end

%%
%计算真实密度的分布
y_true = zeros(Max+1,1);   
for i = 0 : Max
    for j = 1 : Ntotal
        if (x(j) < i+1)&&(x(j) >= i)
            y_true(i+1) = y_true(i+1) + 1;
        end
    end
    y_true(i+1) = y_true(i+1) / Ntotal;
end
 
%%
% 绘图
% 
% figure(1)           %真实密度的分布图象
% bar(t, y_true);
% axis([Min Max+1 0 max(y_true)*1.1]);
% 
% % figure(2)           %核密度估计的密度分布图象
% hold on
% plot(tt, y_KDE,'LineWidth',1.5);
% axis([Min Max 0 max(y_true)*1.1]);