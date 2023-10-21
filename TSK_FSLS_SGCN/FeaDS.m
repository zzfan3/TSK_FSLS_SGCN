function [fea_Lable] = FeaDS(data)
%FEADS 此处显示有关此函数的摘要
[m1,n1]=size(data);
X=data(1:m1,1:n1-1);
Label=data(1:m1,end);
C_frequent=tabulate(Label);
[m2,n2]=size(C_frequent(:,1));
L_class=C_frequent(:,1);
Cell=cell(1,m2);
for n=1:m2
    temp=[];
    i=0;
    for j=1:m1
       if(L_class(n)==Label(j))
           i=i+1;
           temp(i,:)=X(j,:);
       end
       Cell{n}=temp;
    end
end

for i=1:m2
     Mean(i)=mean(mean(Cell{i}));
end
for i=1:m2
    Var(i)=std2(Cell{i});
end
%% 平滑
Mean_smoothdata = smoothdata(Mean,'gaussian');
Var_smoothdata = smoothdata(Var,'gaussian');


Cali_fea=cell(1,m2);
Cell_new=[];
for n=1:m2
    Cali_fea{n}=Var_smoothdata(n)^(-1/2).*Var(n)^(-1/2).*(Cell{n}-Mean(n))+Mean_smoothdata(n);
end

fea_Lable=[];
for i=1:m2
    [m4,n4]=size(Cali_fea{i});
    fea_Lable=[fea_Lable;[Cali_fea{i},ones(m4,1)*L_class(i)]];
end

end

