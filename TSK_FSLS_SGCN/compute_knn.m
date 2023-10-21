function [knn_set] = compute_knn(dataSet,  query,  k)
% return k neighbors index 
numSamples = size(dataSet,1);

% calculate Euclidean distance
tmp = repmat(query,numSamples,1);  % tmp(numSamples,1) = query;
diff = tmp - dataSet;
squaredDiff = diff .^ 2;
squaredDist = sum(squaredDiff, 2);

%sort the distance 
[~, sortedDistIndices] = sort(squaredDist);
if k > length(sortedDistIndices)       % if k < len(sortedDistIndices)
    k = length(sortedDistIndices);
end
knn_set = sortedDistIndices(1:k);   % knn_set = squaredDist(1:k);
end


