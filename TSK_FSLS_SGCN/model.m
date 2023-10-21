function Y = model(parameters,X,A)

ANorm = normalizeAdjacency(A);

Z1 = X;

Z2 = ANorm * Z1 * parameters.mult1.Weights;
% Z2 = relu(Z2) + Z1;
Z2 = relu(Z2);
Z3 = ANorm * Z2 * parameters.mult2.Weights;
% Z3 = relu(Z3) + Z2;
Z3 = relu(Z3);
Z4 = ANorm * Z3 * parameters.mult3.Weights;
Y = softmax(Z4,DataFormat="BC");

end