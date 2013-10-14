function [clustering,centers,eigvecs,eigvals] = GD_SpectralClustering(K,k, normalized)
% Usage: [clustering,centers,eigvecs,eigvals] = GD_SpectralClustering(K,k, normalized)
%
% Input: 
% K =            similarity matrix of size (n,n), needs to be symmetric and non-negative
% k =            number of clusters to construct
%               
% normalized     = 0 means: uses unnormalized Laplacian L = D - K 
%                = 1 means: uses normalized Laplacian D^{-1}L 
%
% Output: 
% clustering:    size = (1,n) result vector with labels 1,...,k
% centers: the centers constructed in the k-means step
% eigvecs: the first eigenvectors of the (normalized or unnormalized) graph Laplacian
% eigvals: the first eigenvalues of the (normalized or unnormalized) graph Laplacian
% 
% We use spectral clustering, as described in "A Tutorial on Spectral Clustering" (Ulrike von Luxburg, available online). 
% In the normalized case we use the eigenvectors of the random walk Laplacian L_rw = D^{-1} (D - K) in the end. 


% ------------------------------------------------------------
% further parameters one can set by hand: 
% ------------------------------------------------------------

% Number of eigenvectors to use: 
% We compute a few more eigvecs for analysis purposes; for clustering I later only use k of thenm; 
num_eigvecs = max([k,10]); 


% ------------------------------------------------------------
% % handle trivial cases and check parameters: 
% ------------------------------------------------------------

num_points = size(K,1);
if (k > num_points)
  clustering = NaN * ones(1,num_points); 
  eigvecs = NaN;
  eigvals = NaN; 
  centers = NaN;
  error('Cannot find more clusters than data points!')
end

if (k==1), clustering = ones(1,num_points); eigvecs = ones(num_points,1); return, end



% ------------------------------------------------------------
% Now start computing: 
% ------------------------------------------------------------


% degree function:
d=zeros(num_points,1);
d=sum(K,2);

% check whether some points have degree zero. As we later need to divide by degree, we have to 
% do something in this case. What we do is: We simply set the degree to some positive number. 
% It does not really matter which number we use, as a point with degree 0 is an isolated 
% point and will form its own connected component anyway. 
% 
if(sum(d==0)>0) 
  disp('Warning: there exist isolated points with degree 0'); 
  d(find(d==0)) = 1/num_points; 
end

% Compute the graph Laplacian, normalized or unnormalized, in sparse representation: 
if (~ normalized) 
  % unnormalized graph Laplacian: A = D - K; 
  A = (spdiags(d,0,num_points,num_points)-K);  
else
  % in the normalized case, to compute the eigenvectors we use the symmetrically normalized matrix 
  % L_sym = D^{-1/2} L D^{-1/2}. 
  % This is numerically more stable. Later on, we will transform the results to the eigs of the 
  % random walk Laplacian L_rw = D^{-1} L
  % Later on we correct for this. 
  Dsqrt =spdiags(1./(d.^0.5), 0, num_points, num_points);
  A = (speye(num_points)-Dsqrt*K*Dsqrt); 
end

% Compute the first eigenvectors of the graph Laplacian: 
[eigvecs,eigvals] = try_compute_eigvecs(A,num_eigvecs);

% In the normalized case, transform eigs of L_sym to those of L_rw: 
% This is done by multiplying the entries of the eigenvectors by sqrt(d). 
% After this we renorm them again to have norm 1. 
if(normalized) 
  for i=1:num_eigvecs
    eigvecs(:,i)=eigvecs(:,i)./sqrt(d);
    eigvecs(:,i)=eigvecs(:,i)/norm(eigvecs(:,i));
  end
end


% now perform k-means on the resulting eigenvectors
[clustering,centers] = try_kmeans(eigvecs(:,1:k), k); %for clustering only use k eigvecs





% ------------------------------------------------------------
% ------------------------------------------------------------
function [eigvecs, eigvals] = try_compute_eigvecs(A,num_eigvecs)
% ------------------------------------------------------------
% ------------------------------------------------------------
% computes the eigenvectors and eigenvalues of A for spectral clustering


num_points = size(A,1);

% A should be symmetric, but due to small numerical errors this might
% not be the case. so force it to be symmetric: 
A = 0.5*(A+A');


try

  % want to look at each connected component of the graph individually.
  % Is numerically more stable if we compute the eigenvectors on the individual components. 
  % But we might end up computing more eigenvectors than absolutely necessary. 
  % 
  % Usually, spectral clustering is called on a connected graph anyway, then this 
  % whole connected component business is not important anyway. 
  
  % compute the connected components: 
  c = GD_GetComps(A);
  NumComps=max(c);
  
  % allocate result vectors: 
  % in each conneted component, we compute up to num_eigvecs eigenvectors:
  revecs=zeros(num_points, NumComps*num_eigvecs);
  revals=zeros(NumComps*num_eigvecs,1);
  
  
  % now go through all connected components and compute the eigenvalues/vectors:
  Counter=1;
  PtsPerComp = zeros(NumComps,1);
  for i=1:NumComps       
    % get points, labels, and adjacency matrix of connected component i: 
    Labels   = find(c==i);
    Rest     = find(c~=i);
    SubMatrix = A(Labels,Labels);
    PtsInComp = length(Labels);
    PtsPerComp(i) = PtsInComp;
    
    % now look at current connected component: 
    if(PtsInComp == 1)
      % if connected component consists of one point: trivial case, know that eigenvector is 1 and eigenvalue is 0.
      evecs=1;
      evals=0;
    else
      % compute the eigenvectors using eig (for small matrices) or eigs (for larger matrices):
      GD_options.disp=0;
      if(PtsInComp>200)
        [evecs,evals]=eigs(SubMatrix,num_eigvecs,'sa', GD_options);
      else
        [evecs,evals]=eig(full(SubMatrix));
      end
    end
    % number of eigenvalues computed. in case we used eig, this will be equal to PtsInComp, 
    % in case we used eigs this will be equal to min(num_eigvecs, PtsInComp)
    NrCompEig = size(evals,1);
    
    % assign eigenvalues in result vector: 
    extract = diag(evals);
    extract = extract(1:min(num_eigvecs,NrCompEig));
    revals(Counter:Counter+min(num_eigvecs,NrCompEig)-1) = extract;
    
    % assign eigenvectors in result vector: 
    % only use the first num_eigvecs ones
    for j=1:min(num_eigvecs,NrCompEig)
      revecs(Labels,Counter+j-1)=evecs(:,j);
    end
    Counter=Counter+min(num_eigvecs,NrCompEig);
  end
  
  % 
  revals=revals(1:Counter-1);
  revecs=revecs(:,1:Counter-1);
  
  % Sort eigenvalues by size
  [eigvals,IX]=sort(revals, 'ascend');
  eigvecs=revecs(:,IX);
  
  if(NumComps > 1) % in case we have more than one connected component we sort the zero eigenvectors by the number of points inside the component (large components first !)
   PtsPerComp = sum(abs(eigvecs(:,1:NumComps))>0,1);
   [PtsPerComp,IX]=sort(PtsPerComp,'descend');
   eigvals(1:NumComps)=eigvals(IX);
   eigvecs(:,1:NumComps)=eigvecs(:,IX);
  end
  
  % finally, pick the first num_eigvecs ones: 
  eigvals=eigvals(1:num_eigvecs);
  eigvecs=eigvecs(:,1:num_eigvecs);
  
catch 
  warning('Could not compute eigenvectors. Spectral clustering NaN')
  eigvecs = NaN; 
  eigvals = NaN;
end 


% ------------------------------------------------------------
% ------------------------------------------------------------
function [clustering,centers] = try_kmeans(eigvecs,k)
% ------------------------------------------------------------
% ------------------------------------------------------------

try % to apply kmeans
  
  % We use Piotr Dollar's kmeans function: 
  [clustering,centers] = KmeansPiotrDollar(eigvecs, k, 'replicates', 30); 

  % If you have a statistics toolbox license, you can also use the kmeans function by matlab: 
  %   [clustering,centers] = kmeansM(eigvecs, k, 'start', 'sample', ...
  %                       'replicates', 30, ...
  %                       'emptyaction', 'singleton'); 

catch 
  warning('kmeans on the eigenvectors did not work. Spectral clustering NaN. '); 
  clustering = NaN * zeros(1,size(eigvecs,1)); 
  centers = NaN; 
end
