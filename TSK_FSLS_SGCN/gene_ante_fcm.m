function [v,b] = gene_ante_fcm(data,options)
% Generate the antecedents parameters of TSK FS by FCM

% data: n_example * n_features
% options.k: the number of rules
% options.h: the adjustable parameter of kernel width 
% of Gaussian membership function.

% return::v: the clustering centers -- k * n_features
% return::b: kernel width of corresponding clustering centers

k = options.k;
h = options.h;
[n_examples, d] = size(data);
% options: exponent for partition matrix & iterations & threshold & display
[v,U,~] = fcm(data,k,[2,NaN,1.0e-6,0]);

for i=1:k
    v1 = repmat(v(i,:),n_examples,1);
    u = U(i,:);
    uu = repmat(u',1,d);
    b(i,:) = sum((data-v1).^2.*uu,1)./sum(uu)./1;
end
b = b*h+eps;


end

