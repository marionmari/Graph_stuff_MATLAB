

addpath(genpath('./'))
addpath(genpath('/home/marion/MATLAB/libsvm-3.17'))

% % LOAD data
% data_path = '../data/GK_benchmark/';
% dataset = 'MUTAG';
% tmp = load([data_path dataset '.mat'])
% break

% data_path = '/home/marion/workspace_IMAGE/ImageAlgorithms/data/sample_regions_selected/';
% dataset = 'plants_graph_data_cerc_gesund1';
% load([data_path dataset '.mat']);

data_path = '../data/ImageData/';
dataset = 'MSRC_9_Nov13'    % 'MSRC_21' 'MSRC_21C'
load([data_path dataset '.mat'])
[ids, imnames] = textread([data_path 'map_id2im_' dataset '.txt'], '%d %s');

labels = cellfun(@(x) strsplit(x,'_'), imnames, 'UniformOutput', false);
labels = cellfun(@(x) str2num(x{1}), labels);


A      = data;
node_labels = responses;
clear('data', 'responses');

% % ASSUMPTION: no graphs removed entirely...
% ids_connected = find(sum(A,2)~=0);
% A = A(ids_connected,ids_connected);
% node_labels = node_labels(ids_connected);
% graph_ind = graph_ind(ids_connected);

num_nodes   = size(A, 1);
num_classes = max(node_labels);
num_graphs = max(graph_ind);



run_pk;

% run_wl;
% run_wl_edge;
% run_wl_sp;
% run_rg;
% run_prw;
% run_rw;
% run_gc
% run_sp;







%---------------------------------------------------------------------%

svm_options = @(c)(['-q  -e 0.01 -m 3000 -t 4 -c ' num2str(c)]);
svm_options_learn = @(c)(['-q -e 0.01 -v 10  -m 3000 -t 4 -c ' num2str(c)]);

% LEARN SVM cost
costs = 10.^(-3:2);
acc_learn = zeros(length(costs),1);
for c=1:length(costs)
    acc_learn(c) = svmtrain_libsvm(labels,[(1:num_graphs)' K], svm_options_learn(costs(c)));
end
[~, id] = max(acc_learn);
% id = 4; % use fixed COST!

fprintf('learned SVM cost: %3f \n',costs(id))
num_folds = 20;  
num_reruns = 1;
ACC = 0;

for r=1:num_reruns
%     c = cvpartition(num_graphs,'kfold',num_folds);
%     save('c.mat', 'c');
%     break
    load('c.mat');
    
    mean_acc = 0;
    for i=1:num_folds
        train_ind = find(training(c,i)==1);
        test_ind = find(training(c,i)==0);  

        K_train = [(1:length(train_ind))' K(train_ind,train_ind)];
        K_test = [(1:length(test_ind))' K(test_ind,train_ind)];


%         % LEARN SVM cost~
%         costs = 10.^(-3:2);
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

