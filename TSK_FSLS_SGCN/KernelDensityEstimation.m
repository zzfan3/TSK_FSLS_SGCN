% Kernel Density Estimation
% ֻ�ܴ����������ܶ�
function [t, y_true, tt, y_KDE] = KernelDensityEstimation(x)
% clear

% x = px_last;
% x = px_last_tu;
%%
%������ʼ��
Max = round(max(x));           %���������ֵ
Min = round(min(x));           %��������Сֵ
Ntotal = length(x);     %���ݸ���
tt = 0 : 0.01 : Max;     %��ȷx��

t = 0 : Max;            %����x��

y_KDE = zeros(100 * Max+1, 1);   %���ܶȹ���ֵ
sum1 = 0;                       %��͵��м����
%%
%�������h
R = 1/(2*sqrt(pi));
m2 = 1;
h = 3;
% h = (R)^(1/5) / (m2^(2/5) * R^(1/5) * Ntotal^(1/5));

%%
%������ܶȹ���
for i = 0 : 0.01 : Max        
    for j = 1 : Ntotal
        sum1 = sum1 + normpdf(i-x(j));
    end
    y_KDE(round(i*100+1)) = sum1 / (h * Ntotal);
    sum1 = 0;
end

sum2 = sum(y_KDE)*0.01;  %��һ��KDE�ܶ�
for i = 0 : 0.01 : Max
    y_KDE(round(i*100+1)) = y_KDE(round(i*100+1))/sum2;
end

%%
%������ʵ�ܶȵķֲ�
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
% ��ͼ
% 
% figure(1)           %��ʵ�ܶȵķֲ�ͼ��
% bar(t, y_true);
% axis([Min Max+1 0 max(y_true)*1.1]);
% 
% % figure(2)           %���ܶȹ��Ƶ��ܶȷֲ�ͼ��
% hold on
% plot(tt, y_KDE,'LineWidth',1.5);
% axis([Min Max 0 max(y_true)*1.1]);