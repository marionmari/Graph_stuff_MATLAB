

addpath(genpath('/Users/marion/workspace/CWK_stuff/'))

% READ data
data_path = '/Users/marion/workspace/DATA/';
dataset = 'MUTAG';
data = load([data_path 'GK_benchmark/' dataset '.mat']);

% dataset = 'MSRC_21C'    % 'MSRC_21' 'MSRC_9'
% data = load([data_path 'ImageData/' dataset '.mat'])


labels = double(data.labels);       % graph labels

num_graphs = length(labels)
node_labels = data.responses;
graph_ind = double(data.graph_ind);
A = data.A;

% ASSUMPTION: no graphs removed entirely...
ids_connected = find(sum(A,2)~=0);
A = A(ids_connected,ids_connected);
node_labels = node_labels(ids_connected);
graph_ind = graph_ind(ids_connected);

% row-normalize adjacency matrix!
if find(sum(A,1)~=1)
  A = bsxfun(@times, A, 1./sum(A,2));  
end


USE_DIFF = false;
node_label_ind = (1:size(graph_ind,1));

%---------------------------------------------------------------------%
if USE_DIFF
    % COMPUTE diffusion graph kernel
    use_pushback = false;
    take_sum = true;

    % kernel parameter(s)
    max_height = 10;
    w = 1e-5;
    use_cauchy = false;

    K = propagation_kernel(A, graph_ind, node_labels, node_label_ind, ...
                                max_height, w, use_cauchy, use_pushback, take_sum);
else

    % COMPUTE coinciding walk graph kernel
    walk_length = 25;
    alpha = 0.1
    K_nodes = short_walk_kernel_full(A, node_labels, node_label_ind, walk_length, 'alpha', alpha);
    
    K = zeros(num_graphs);
    for i=1:num_graphs
        for j=1:i
            K_tmp = K_nodes(graph_ind==i,graph_ind==j);
            K(i,j)= mean(K_tmp(:));
        end
    end
    K = K + K' - diag(diag(K));
end

%---------------------------------------------------------------------%

svm_options = @(c)(['-q  -e 0.01 -m 3000 -t 4 -c ' num2str(c)]);
svm_options_learn = @(c)(['-q -e 0.01 -v 10  -m 3000 -t 4 -c ' num2str(c)]);

% LEARN SVM cost
costs = 10.^(3:5);
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


%         % LEARN SVM cost~
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
    mean_acc = mean_acc./num_folds;
    ACC = ACC + mean_acc;
end
ACC = ACC/num_reruns

