function [loss,gradients] = modelLoss(parameters,X,A,T)

Y = model(parameters,X,A);
loss = crossentropy(Y,T,DataFormat="BC");
gradients = dlgradient(loss, parameters);

end
