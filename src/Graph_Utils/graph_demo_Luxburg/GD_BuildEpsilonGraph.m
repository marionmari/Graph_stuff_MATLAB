function W = GD_BuildEpsilonGraph(M,t,which_matrix)
% Usage: W = GD_BuildEpsilonGraph(M,t,which_matrix)
%
% Input: 
% M                = either distance matrix or similarity matrix, needs to be square and symmetric
% t                = threshold of the eps graph
% which_matrix     = 'sim' or 'dist'
% 
% Output: 
% W              = adjacency matrix of the epsilon-neighborhood graph
%
% For a distance matrix: connects all points with distanace M(it,jt) <= t, returns an unweighted graph. 
% For a similarity matrix: connects all points with similarity M(it,jt) >= t, and weights the edges by the similarity.

%implemented brute force 

if (size(M,1) ~= size(M,2))
  error('Matrix not square!')
end
n = size(M,1);


if (strcmp(which_matrix,'sim'))
  
  % to exclude self-edges, set diagonal to 0
  for it=1:n
    M(it,it) = 0; 
  end
 
  W = (M >= t) .* M; 
  
%  W = +W; % make it numeric rather than logical

  
  
elseif (strcmp(which_matrix, 'dist'))
  
  
  % to exclude self-edges, set diagonal of sim/dissim matrix to Inf or 0
  for it=1:n
    M(it,it) = Inf; 
  end
  
  W = (M <= t); 
  W = +W; % make it numeric rather than logical

  
  
else
  error('Unknown matrix type')
end
  
  
