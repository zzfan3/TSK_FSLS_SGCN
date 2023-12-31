clc
clear
close all

%% code from GAOSI 请使用新版matlab运行此程序，此程序开发环境在matalbR2022b
%% GCN 
load('Vehicle.mat');

X=data(:,1:end-1);
labels=data(:,end);

 knn_num_neighbors=10;
[affinity_matrix] = buildGraph(X, knn_num_neighbors);

adjacencyData=affinity_matrix;
[numObservations,~] = size(adjacencyData);
[idxTrain,idxValidation,idxTest] = trainingPartitions(numObservations,[0.3 0.2 0.5]);

ATrain = adjacencyData(idxTrain,idxTrain);
AValidation = adjacencyData(idxValidation,idxValidation);
ATest = adjacencyData(idxTest,idxTest);

XTrain = X(idxTrain,:);
XValidation = X(idxValidation,:);
XTest =X(idxTest,:);

labelsTrain = labels(idxTrain,:);
labelsValidation = labels(idxValidation,:);
labelsTest = labels(idxTest,:);

% 使用训练特征的均值和方差对特征进行归一化。使用相同的统计数据规范化验证要素。
muX = mean(XTrain);
sigsqX = var(XTrain,1);
XTrain = (XTrain - muX)./sqrt(sigsqX);
XValidation = (XValidation - muX)./sqrt(sigsqX);
%% 创建包含模型参数的结构
% 使用函数初始化可学习的权重initializeGlorot
parameters = struct;

numHiddenFeatureMaps = 32;
numInputFeatures = size(XTrain,2);

sz = [numInputFeatures numHiddenFeatureMaps];
numOut = numHiddenFeatureMaps;
numIn = numInputFeatures;
parameters.mult1.Weights = initializeGlorot(sz,numOut,numIn,"double");
% 初始化第二个乘法运算的权重。初始化权重以具有与上一个乘法运算相同的输出大小。输入大小是上一个乘法运算的输出大小。
sz = [numHiddenFeatureMaps numHiddenFeatureMaps];
numOut = numHiddenFeatureMaps;
numIn = numHiddenFeatureMaps;
parameters.mult2.Weights = initializeGlorot(sz,numOut,numIn,"double");
% 初始化第三次乘法运算的权重。初始化权重，使其输出大小与类数匹配。输入大小是上一个乘法运算的输出大小。
% classes = categories(labelsTrain);
% numClasses = numel(classes);
C_frequent=tabulate(labelsTrain);
classes=C_frequent(:,1);
numClasses = numel(classes);


sz = [numHiddenFeatureMaps numClasses];
numOut = numClasses;
numIn = numHiddenFeatureMaps;
parameters.mult3.Weights = initializeGlorot(sz,numOut,numIn,"double");


%% 定义模型函数
% 指定训练选项
% 训练 1500 个 epoch，并将 Adam 求解器的学习率设置为 0.01。
% numEpochs = 1500;

numEpochs = 1500;
learnRate = 0.01;
% 每 300 个纪元验证一次网络。
validationFrequency = 300;

% 训练模型
% 初始化训练进度图
figure
C = colororder;
lineLossTrain = animatedline(Color=C(2,:));
lineLossValidation = animatedline( ...
    LineStyle="--", ...
    Marker="o", ...
    MarkerFaceColor="black");
ylim([0 inf])
xlabel("Epoch")
ylabel("Loss")
grid on
% 初始化parameters for Adam.
trailingAvg = [];
trailingAvgSq = [];
% 将训练和验证特征数据转换为对象。dlarray
XTrain = dlarray(XTrain);
XValidation = dlarray(XValidation);
% GPU 上训练
if canUseGPU
    XTrain = gpuArray(XTrain);
end
% 使用函数将训练和验证标签转换为one-hot encoded vectors
TTrain = onehotencode(labelsTrain,2,ClassNames=classes);
TValidation = onehotencode(labelsValidation,2,ClassNames=classes);
% 使用自定义训练循环训练模型。训练使用全批次梯度下降。
% 使用和函数评估模型损失和梯度。dlfevalmodelLoss
% 使用更新网络参数。adamupdate
% 更新训练图。
% 如果需要，通过使用函数进行预测并绘制验证损失来验证网络。model
start = tic;

for epoch = 1:numEpochs
    % Evaluate the model loss and gradients.
    [loss,gradients] = dlfeval(@modelLoss,parameters,XTrain,ATrain,TTrain);

    % Update the network parameters using the Adam optimizer.
    [parameters,trailingAvg,trailingAvgSq] = adamupdate(parameters,gradients, ...
        trailingAvg,trailingAvgSq,epoch,learnRate);

    % Update the training progress plot.
    D = duration(0,0,toc(start),Format="hh:mm:ss");
    title("Epoch: " + epoch + ", Elapsed: " + string(D))
    loss = double(loss);
    addpoints(lineLossTrain,epoch,loss)
    drawnow

    %Display the validation metrics.
    if epoch == 1 || mod(epoch,validationFrequency) == 0
        YValidation = model(parameters,XValidation,AValidation);
        lossValidation = crossentropy(YValidation,TValidation,DataFormat="BC");

        lossValidation = double(lossValidation);
        addpoints(lineLossValidation,epoch,lossValidation)
        drawnow
    end
end
%% Test Model
% 使用测试数据测试模型。
% % 使用与训练和验证数据相同的步骤预处理测试数据。
XTest = (XTest - muX)./sqrt(sigsqX);
% 将测试特征数据转换为对象。dlarray
XTest = dlarray(XTest);
% 对数据进行预测，并使用函数将概率转换为分类标签。
Y_presemi = model(parameters,XTest,ATest);
Y_presemi = onehotdecode(Y_presemi,classes,2);
Y_presemi=double(Y_presemi);
% 计算精度
accuracy = mean(Y_presemi == labelsTest);

%% 训练标签不足的TSK
% Parameter settings
options.omega = 1;
options.k = 5;
options.h = 1;
[n_tr,~] = size(XTrain);
X_train=extractdata(XTrain);
Y_train=labelsTrain;
X_te=extractdata(XValidation);
Y_te=labelsValidation;
%% Train and test the model

%% 充足标签的TSK_SGCN
X_test=extractdata(XTest);
X_train2=[X_train;X_test];
Y_train2=[Y_train;Y_presemi];
[train_acc2, test_acc2 ] = TSK(X_train2,Y_train2,X_te,Y_te,options);
TSK_SGCN=test_acc2

%% TSK_LSFS_SGCN
data=[X_train2,Y_train2];
%原特征经过特征平滑（Feature Smoothing）处理,使用函数FeaDS
[fS_data]=FeaDS(data);
X_train3=fS_data(:,1:end-1);
Y_train3=fS_data(:,end);
[train_acc3, test_acc3 ] = TSK_LS(X_train3,Y_train3,X_te,Y_te,options);
TSK_SGCN_LS_FS=test_acc3




