function [f,coeff] = GD_GetSSLSolution(K,targets, laplacian, lambda, MuRegul)
% a k - nearest neighbor graph is build with (KNNDist and KNN)
% The weight matrix is then generated via getSparseWeightMatrixFromKNN with
% gammaVal as the parameter for the Gaussian weights
%
% Finally using this weight matrix the graph Laplacian is built
% (unnormalized or random walk) depending on the value of laplacian
% and the semi-supervised learning problem
%
% min <y-f,y-f> + \mu <f,L f> 
%
% with y=targets is solved
%
% output: the solution f and the coefficient <f,Lf>/<f,f>

% get number of data points
num = size(K,2);

% the following code is only used for lambda~=0
if(lambda~=0)
    % build the degree function ( d_i = sum_j w_ij)
    d=sum(K,2);
    % checks if elements of the degree function are zero and correct this
    if(sum(d==0)>0)
        disp('Warning, Elements of d are zero');
        for i=1:num
            if(d(i)==0), d(i)=1/(num); end
        end
    end
    % builds the final weight matrix - reweighted by some power of the degree
    % function \tilde{k}_ij = k_ij / pow(d_i d_j, lambda)
    f=spdiags(1./(d.^lambda), 0, num, num);
    K=1/(num)*f*K*f;
    clear f;
    clear d;
end

% final degree function of weights \tilde{k}
e=sum(K,2);
if(sum(e==0)>0)
    disp('Warning, Elements of e are zero');
    for i=1:num
        if(e(i)==0), e(i)=1/(num); end
    end
end

% normalization factor
E=spdiags(e,0,num,num);
gammaFactor = MuRegul*num;

% labeled indicator matrix
LabInd = targets(:,1)~=0;
LabIndices=find(LabInd==1);
IndLab = spdiags(LabInd,0,num,num);
c =GD_GetComps(K);
Reachable=zeros(num,1);
NonReachable=ones(num,1);
for i=1:length(LabIndices)
 Reachable(find(c==c(LabIndices(i))))=1;
end
ReachableInd=find(Reachable==1);


switch laplacian % we solve here Ax=b using cholmod, cholmod will be standard to solve Ax=b for sparse, pd, symmetric
                 % matrices from matlab version 7.2 on 
    case 0, %normalized, solve (Id + gamma*L)*x =target, where L=Id - E^{-1}W               
            % we have multiplied here the whole equation with E to
            % transform the problem into a symmetric one so that we
            % can use cholmod, problems could arise if e is zero
            % somewhere which we explicitly avoid above
            % f=cholmod((1+gammaFactor)*E-gammaFactor*K,E*targets);
            
            % loss only on labeled data
            %A = IndLab*E*IndLab+gammaFactor*E-gammaFactor*K;
            
            % loss also on unlabeled data
            A = (1+gammaFactor)*E-gammaFactor*K;
            
            A = A(ReachableInd,ReachableInd);
            b = E*targets;
            b = b(ReachableInd,:);
            sol = A\b;
            f=zeros(num,size(b,2));
            f(ReachableInd,:)=sol;
            
            NaNInd = find(isnan(f(:,1)));
            if(length(NaNInd)>0)
             f(NaNInd,:)=0;
             display('Solution contains NaN Elements');
            end
            
            coeff=zeros(size(f,1),size(f,2));

            
    case 1, %unnormalized, solve (Id + gamma*L)*x =target, where L=E-W  
            % loss only on labeled data
            A = IndLab +gammaFactor*(E-K);
            % loss also on unlabeled data
            %A = speye(num)+gammaFactor*(E-K);
            
            f=A\targets; 
            coeff=zeros(size(f,1),size(f,2));
            %coeff = f'*K*f / f'*f;  
            %for i=1:size(b,2), coeff(i)=f(:,i)'*K*f(:,i) / f(:,i)'*(e.*f(:,i)); end
            %coeff = getCorrelation(f,K,e);
            %dev = max(abs(A*f-targets));
            
    case 2, E=spdiags(1./(e.^0.5), 0, num, num);
            K=E*K*E; 
            % loss only on labeled data
            %A = IndLab +gammaFactor*(speye(num) - K);
            % loss also on unlabeled data
            A = speye(num) + gammaFactor*(speye(num) - K);
            
            A = A(ReachableInd,ReachableInd);
            f=zeros(num,size(targets,2));
            f(ReachableInd,:)=A\targets(ReachableInd,:);
            coeff=zeros(size(f,1),size(f,2));
end
