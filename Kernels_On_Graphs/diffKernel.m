function K = diffKernel(A, beta)
% DIFFUSION KERNEL on graph
% 
%   K = exp(beta*H), where H = -L_ = A-D
%   K = Q exp(beta * Lambda) Q', where H = Q Lambda Q'
%
% INPUT: 
%       A           adjacency matrix
%       beta        default: 0.5
%
% OUTPUT:
%       K           kernel matrix
%
    if nargin==1
        beta = 0.5;
    end

    H = A - diag(sum(A,2));
    
    [V,D] = eig(H);                 % A*V = V*D, D eigenvalues, V eigenvectors 
    Lambda = exp(beta*D);
    
    K = V*D*V';
    
end

