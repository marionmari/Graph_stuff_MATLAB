num_train      = 1e3;
num_iterations = 10;
w              = 1e-4;
distance       = 'l1';

load('~/MSRC_9class_ECML');

A      = data;
labels = responses;
clear('data', 'responses');

num_nodes   = size(A, 1);
num_classes = max(labels);

train_ind       = randperm(num_nodes, num_train);
observed_labels = labels(train_ind);

initial_features = prior_label_distributions(A, train_ind, ...
        observed_labels, num_classes);

transformation = @(features) label_propagation(features, A, train_ind, ...
        observed_labels);

K = propagation_kernel(initial_features, graph_ind, transformation, ...
                       num_iterations, ...
                       'distance', distance, ...
                       'w',        w);