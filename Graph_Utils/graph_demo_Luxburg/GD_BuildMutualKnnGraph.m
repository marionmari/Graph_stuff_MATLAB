function W = BuildMutualKnnGraph(M,k,which_matrix)
% Usage:  W = BuildMutualKnnGraph(M,k,which_matrix)
%
% Input: 
% M                = either the distance or the similarity matrix, needs to be square, symmetric, non-negative
% k                = connectivity parameter of the kNN graph
% which_matrix     = either 'sim' or 'dist' (similarity or distance matrix)
% 
% Output: 
% W              = adjacency matrix of the mutual kNN graph
%
%
% For a similarity matrix S, returns the mutual knn graph, edges are weighted by S. 
% For a distance matrix D, returns the undirected (unweighted!) mutual  knn graph. If you want to get 
% a weighted graph in this case, you need to take care of transforming D to S yourself and then 
% call the function with a similarity matrix 
%
% Self edges are excluded in both cases. 

% check: 
if (size(M,1) ~= size(M,2))
  error('Matrix not square!')
end

% build the directed knn graph: 
W = GD_BuildDirectedKnnGraph(M,k,which_matrix); 

% transform it to the mutual one: 
W = min(W,W'); 
