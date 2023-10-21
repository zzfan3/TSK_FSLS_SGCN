function [W_n] = LabDS(y0)
%% ��ǩ�ֲ�ƽ��
C_frequent=tabulate(y0);
% y_LabelFre=C_frequent(:,3)*0.01;
% y_LabelFre=C_frequent(:,3);
%% ƽ��
[t, y_true, tt, y_KDE] = KernelDensityEstimation(y0);
Max = round(max(y0));       
Min = round(min(y0));
[i_long,j_long]=size(y_KDE);
y_KDE(i_long)=[];
y_KDE=y_KDE';
%���������ݣ�ÿ10��ȡƽ��
sum2=zeros(100,1);%the sum
s_y_true=zeros(Max ,1);%the average
for j=1:Max 
sum2(j)=sum(y_KDE(100*(j-1)+1:100*j));
s_y_true(j)=sum(y_KDE(100*(j-1)+1:100*j))/100;%ave1Ϊ��������������������������
end
% xlswrite('F:\data\data use\1.xlsx',ave2,'sheet2')%���д��excel���

% figure(3)
% % s_y_true=[0;s_y_true];%��ʵ�ܶȵķֲ�ͼ��
% t=1:1:Max ;
% bar(t, s_y_true);
%    
% axis([Min Max 0 max(y_true)*1.1]);

yLabelFre_smoothdata =s_y_true;
% yLabelFre_smoothdata=y_LabelFre*0.01;
%% ����Ȩ��
L_classfre=C_frequent(:,2);
[m,n]=size(L_classfre);
W=[];
for i=1:m
  W=[W;yLabelFre_smoothdata(i)*ones(L_classfre(i),1)];
end
W=1./(W);
W_n=diag(W);
end

