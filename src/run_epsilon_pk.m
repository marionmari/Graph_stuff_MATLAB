

addpath(genpath('../data'))
addpath(genpath('./'))
addpath(genpath('/home/marion/MATLAB/libsvm-3.17'))

%---------------------------------------------------------------------%
% LOAD point clouds
% pcs:              point clouds 
% node_labels:      node labels
% graph_ind:        graph identifier
% A:                knn-graphs (k=4) [baseline graphs]
% labels:           graph labels
read_DB_data()

num_graphs = max(graph_ind)        % number of graphs

%---------------------------------------------------------------------%
% FIND median distance of points in all pcs and prepare figure
figure;
tmp = 1;
pairwise_dists = [];
median_pairwise_dists = [];
for i=1:num_graphs

    curr_pc = pcs((graph_ind==i),:);
    curr_pw_dist = pdist(curr_pc)';
%     median(curr_pw_dist)
%     median_pairwise_dists = [median_pairwise_dists; median(curr_pw_dist)];
    pairwise_dists = [pairwise_dists; curr_pw_dist];
    
    
    subplot(num_graphs+1,num_graphs,i);
    plot_object(curr_pc, tmp, node_labels((graph_ind==i),:), true);
end

median_dist = median(pairwise_dists)
% median(median_pairwise_dists)
% break
% range_xyz = abs(min(curr_pc)-max(curr_pc));
% plot_object(curr_pc, A, node_labels((graph_ind==1),:), false);
inc = 0.03;
eps_range = (0.01:inc:0.2)*median_dist


%---------------------------------------------------------------------%
% SET parameters for diffusion graph kernel (PK)
use_pushback = false;
take_sum = true;
labeled_nodes_ind = (1:size(graph_ind,1));

% kernel parameter(s)
max_height = 10;
w = 1e-5;
use_cauchy = false;

K = zeros(num_graphs,num_graphs,length(eps_range));

for j=1:length(eps_range)
    eps = eps_range(j);
    
    % CREATE epsNN-graphs
    A_eps = [];
    for i=1:num_graphs
        curr_pc = pcs((graph_ind==i),:);
        pw_dist_matrix = squareform(pdist(curr_pc));
        
        curr_A_eps = GD_BuildEpsilonGraph(pw_dist_matrix,eps,'dist');

        A_eps = sparse(blkdiag(A_eps,curr_A_eps));
    end
    
    
    % COMPUTE PK
    K_tmp = propagation_kernel(A_eps, graph_ind, node_labels, labeled_nodes_ind, ...
                                max_height, w, use_cauchy, use_pushback, take_sum);

    norms = 1 ./ sqrt(diag(K_tmp));
    K_norm = bsxfun(@times, norms, bsxfun(@times, norms', K_tmp));
                            
    K(:,:,j) =  K_norm;
end                 
for i=1:num_graphs
    for j=i+1:num_graphs
        subplot(num_graphs+1,num_graphs,num_graphs+sub2ind([num_graphs,num_graphs], j,i));
        plot(eps_range, squeeze(K(i,j,:)))
        axis([0 max(eps_range) 0  1])
        
        subplot(num_graphs+1,num_graphs,num_graphs+sub2ind([num_graphs,num_graphs], i,j));
        plot(eps_range, squeeze(K(i,j,:)))
        axis([0 max(eps_range) 0  1])
    end
end
break


                        
%---------------------------------------------------------------------%
% EVALUATION
svm_options = @(c)(['-q  -e 0.01 -m 3000 -t 4 -c ' num2str(c)]);
svm_options_learn = @(c)(['-q -e 0.01 -v 10  -m 3000 -t 4 -c ' num2str(c)]);

% LEARN SVM cost
costs = 10.^(-3:1);
acc_learn = zeros(length(costs),1);
for c=1:length(costs)
    acc_learn(c) = svmtrain_libsvm(labels,[(1:num_graphs)' K], svm_options_learn(costs(c)));
end
[~, id] = max(acc_learn);
fprintf('learned SVM cost: %3f \n',costs(id))
% id = 2;


num_folds = 10;  
num_reruns = 10;
ACC = 0;

for r=1:num_reruns
    
    indices = crossvalind('Kfold', num_graphs, num_folds);
    mean_acc = 0;
    for i=1:num_folds
        train_ind = find(indices~=i);
        test_ind = find(indices==i);
        K_train = [(1:length(train_ind))' K(train_ind,train_ind)];
        K_test = [(1:length(test_ind))' K(test_ind,train_ind)];


%         % LEARN SVM cost
%         costs = 10.^(-3:3);
%         acc_learn = zeros(length(costs),1);
%         for c=1:length(costs)
%             acc_learn(c) = svmtrain_libsvm(labels(train_ind),K_train, svm_options_learn(costs(c)));
%         end
%         [~, id] = max(acc_learn);
%         fprintf('learned SVM cost: %3f \n',costs(id))


        % SVM prediciton
        model = svmtrain_libsvm(labels(train_ind),K_train, svm_options(costs(id)));
        [y_pred, acc, decision_vals] = svmpredict(labels(test_ind),K_test, model, '-q');
        acc = acc(1);
        mean_acc = mean_acc + acc;


    end
    mean_acc = mean_acc./num_folds
    ACC = ACC + mean_acc;
end
ACC = ACC/num_reruns

