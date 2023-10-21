function [train_acc, test_acc] = TSK_LS(X_train,Y_train,X_test,Y_test,options)
% X_train: n_tr * n_features
% Y_train: n_tr * 1
% X_test: n_te * n_features
% Y_test: n_te * 1
% options:
% options.omega: % regularization parameter for ridge regression TSK
% options.k: number of fuzzy rules
% options.h: adjustable parameter for fcm used for generating antecedent
%             parameters.


% Unitization. Other preprocessing techniques also can be used according 
% to your requirements such as 'normalization' or 'standardization'
[n_tr,~] = size(X_train);

X_uni = [X_train',X_test'];
X_uni = X_uni*diag(sparse(1./sqrt(sum(X_uni.^2))));
X_uni_train = X_uni(:,1:n_tr)';
X_uni_test = X_uni(:,(n_tr+1):end)';

D_train = X_uni_train;
D_test = X_uni_test;


% Get antecedent parameters and the transformed data in fuzzy feature space
% There are two ways to generate the antecedent parameters: 'deter' or 'fcm'
% 'deter' generate the antecedent parameters deterministically and 'fcm' 
% generate the antecedent parameters with randomness.

% Here the antecedent parameters also can be generated with only the
% training data like the other unsupervised learning methods, such as PCA.

% [v_train,b_train] = gene_ante_fcm(D_train,options);
% [v_test,b_test] = gene_ante_fcm(D_test,options);

[v_train,b_train] = gene_ante_deter(D_train,options);
[v_test,b_test] = gene_ante_deter(D_test,options);

G_train = calc_x_g(D_train,v_train,b_train);
G_test = calc_x_g(D_test,v_test,b_test);

% Solve the consequence parameters 
y_ooh_train = y2ooh(Y_train,length(unique(Y_train)));

%% 
y_ooh_test = y2ooh(Y_test,length(unique(Y_test)));
num_class = length(unique(Y_train));%10

y_pred_train = zeros(size(G_train,1),num_class);%6509行，10列 的零 初始化的过程
y_pred_test = zeros(size(G_test,1),num_class);


%% 标签分布平滑 LS
[W_n] = LabDS(Y_train);
%% 
omega = options.omega; 
% Construct K TSK classifiers
for k=1:num_class
    y_train_temp = y_ooh_train(:,k);
%     P = lms(G_train,y_train_temp); % can be replaced with lms线性回归
%     P = lms_W(G_train,y_train_temp,W_n);
      
%       P = lms_l2(G_train,y_train_temp,omega);
    %选用标签平滑（LS）后的W_n
    P= lms_l2W(G_train,y_train_temp,omega,W_n);

    y_pred_train(:,k) = G_train*P;
    y_pred_test(:,k) = G_test*P;
end

[train_acc, test_acc] = calcu_acc_ooh(y_pred_train,...
        y_pred_test, Y_train, Y_test);

end


function [train_acc, test_acc] = calcu_acc_ooh(train_y_predict, test_y_predict, train_y, test_y)
% calculate the accuary from the multiple results which are the
% 'one-of-hot' forms.
[~, train_max_index] = max(train_y_predict');
train_max_index = train_max_index';
dis_train_y = train_max_index - train_y;
train_diff = find(dis_train_y~=0);
num_train_diff = size(train_diff, 1);
train_acc =1-(num_train_diff/size(train_y, 1));

[~, test_max_index] = max(test_y_predict');
test_max_index = test_max_index';
dis_test_y = test_max_index - test_y;
test_diff = find(dis_test_y~=0);
num_test_diff = size(test_diff, 1);
test_acc = 1-(num_test_diff/size(test_y, 1));

end


function c = lms(x_g,y)

% calculate the least square solution of the x_g and y
c = (x_g'*x_g)\(x_g'*y);
if sum(isnan(c))>0
    error('calculate results contains NaN!!!!!!!!!!!!');  
end
end

function c = lms_l2(x_g,y,omega)
% calculate the least square solution of the x_g and y
% ridge regression is used here
A = x_g'*x_g;
B = eye(size(A,1));
c = (A+omega*B)\(x_g'*y);
if sum(isnan(c))>0
    error('calculate results contains NaN!!!!!!!!!!!!');  
end
end

function c = lms_W(x_g,y,W_n)
% calculate the least square solution of the x_g and y
c = (x_g'*W_n*x_g)\(x_g'*W_n*y);
if sum(isnan(c))>0
    error('calculate results contains NaN!!!!!!!!!!!!');  
end
end

function c = lms_l2W(x_g,y,omega,W_n)
% calculate the least square solution of the x_g and y
% ridge regression is used here
A = x_g'*W_n*x_g;
B = eye(size(A,1));
c = (A+omega*B)\(x_g'*W_n*y);
if sum(isnan(c))>0
    error('calculate results contains NaN!!!!!!!!!!!!');  
end
end

function [ data_y_ooh ] = y2ooh( y_label, num_classes )
% Transform the labels to the form of 'one-of-hot'
n_examples = size(y_label, 1);
data_y_ooh = zeros(n_examples, num_classes);
for i=1:n_examples
    index = y_label(i, :);
    data_y_ooh(i, index) = 1;
end
end




