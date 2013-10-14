function K = regLapKernel(A, sigma)
% REGULARIZED LAPLACIAN KERNEL on graph
% 
%   K = (I + sigma^2*L)^-1, where   L = D^-1/2*L_*D^-1/2 = I-D^-1/2*A*D^-1/2
%                           and     L_ = D-A       
%
% INPUT: 
%       A           adjacency matrix
%       sigma       default = 1
%
% OUTPUT:
%       K           kernel matrix
%

    if nargin==1
        sigma = 1;
    end
    
    D = sum(A,2);
 
    % normalized Laplacian
    D(D~=0)=sqrt(1./D(D~=0));
    D=spdiags(D,0,speye(size(A,1)));
    W=D*A*D;
    L=speye(size(W,1))-W;
    
    K = inv(speye(size(A,1))+sigma^2*L);
    
end

