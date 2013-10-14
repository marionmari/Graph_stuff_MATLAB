function K = psInvLapKernel(A)
% PSEUDO INVERSE of the (normalized) LAPLACIAN KERNEL on graph
% 
%   K = (L)^+ , where L = D^-1/2*L_*D^-1/2 = I-D^-1/2*A*D^-1/2
%               and   L_ = D-A    
%
%
% INPUT: 
%       A           adjacency matrix
%

    D = sum(A,2);
 
    % normalized Laplacian
    D(D~=0)=sqrt(1./D(D~=0));
    D=spdiags(D,0,speye(size(A,1)));
    W=D*A*D;
    L=speye(size(W,1))-W;
    
    K = pinv(L);

end