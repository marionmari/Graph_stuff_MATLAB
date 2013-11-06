
fprintf('...row normalization\n')
% row-normalize adjacency matrix!
A = spdiags(1./sum(A,2),0,size(A,1),size(A,1))*A;


num_train   = num_nodes*0.6;    % 1e3;
num_iter    = 10;               % kernel height
w           = 1e-4;             % bin width
distance    = 'tv';
% train_ind       = randperm(num_nodes, num_train);
% save('train_ind.mat', 'train_ind')
% break
load('train_ind.mat')
observed_labels = node_labels(train_ind);

initial_features = prior_label_distributions(A, train_ind, observed_labels, num_classes);

if num_train == num_nodes  
    transformation = @(features) label_diffusion(features, A); % DIFFUSION   
else
    transformation = @(features) label_propagation(features, A, train_ind, observed_labels); % LABEL PROPAGATION
end

fprintf('...propagation kernel computation\n')
K = propagation_kernel(initial_features, graph_ind, transformation, num_iter, 'distance', distance, 'w', w);