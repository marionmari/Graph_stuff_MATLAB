num_nodes = size(A, 1);

% diagonal degree matrix
D = full(sum(A));

% laplacian
L = diag(D) - A;
% normalized laplacian
L_hat = diag(1 ./ sqrt(D)) * L * diag(1 ./ sqrt(D));
% negative laplacian
H = -L;
S = diag(1 ./ sqrt(D)) * A * diag(1 ./ sqrt(D));

% row-normalized adjacency matrix
A = bsxfun(@times, 1 ./ sum(A, 2), A);

% % K_pseudoinverse = pinv(L_hat);
% % K_regularized_laplacian = ...
% %     inv(eye(num_nodes) + regularized_laplacian_sigma^2 * L_hat);
% % K_diffusion = expm(beta * H);
K_spreading = inv(speye(size(A,1))-spreading_alpha*S);

% [num_components, assignments] = graphconncomp(A, 'directed', false);

% K_pseudoinverse         = zeros(num_nodes);
% K_regularized_laplacian = zeros(num_nodes);
% K_diffusion             = zeros(num_nodes);

% for i = 1:num_components
%   ind = (assignments == i);
%   K_pseudoinverse(ind, ind) = pinv(L_hat(ind, ind));
%   K_regularized_laplacian(ind, ind) = ...
%       inv(eye(nnz(ind)) + regularized_laplacian_sigma^2 * L_hat(ind, ind));
%   K_diffusion(ind, ind) = expm(beta * H(ind, ind));
% end
