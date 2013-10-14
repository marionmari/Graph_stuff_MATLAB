function K = VNDKernel(A, alpha)
% VON NEUMANN DIFFUSION KERNEL on graph (Zhou et al., 2004)
% (also label spreading kernel)
%
%   K = (I - alpha*S)^-1, where S = D^-1/2*A*D^-1/2
%
% INPUT: 
%       A           adjacency matrix
%       alpha       default: 0.5
%
% OUTPUT:
%       K           kernel matrix
%
    if nargin==1
        alpha = 0.5;
    end
    
    D = sum(A,2);
 
    D(D~=0)=sqrt(1./D(D~=0));
    D=spdiags(D,0,speye(size(A,1)));
    S=D*A*D;
    
    K = inv(speye(size(A,1))-alpha*S);

end