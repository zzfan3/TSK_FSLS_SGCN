function [affinity_matrix] = buildGraph(MatX, knn_num_neighbors)
% build a big graph (normalized weight matrix)  
num_samples = size(MatX,1);
affinity_matrix = zeros(num_samples, num_samples, 'double');
if isempty(knn_num_neighbors)
    disp('You should input a k of knn!')
end
for i = 1:num_samples
    k_neighbors = compute_knn(MatX, MatX(i, :), knn_num_neighbors);
    affinity_matrix(i, k_neighbors) = 1.0 / knn_num_neighbors;
end
end