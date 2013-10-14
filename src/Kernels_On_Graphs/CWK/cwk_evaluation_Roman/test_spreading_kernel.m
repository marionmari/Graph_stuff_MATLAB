num_nodes         = size(A, 1);

spreading_accuracies                      = zeros(num_experiments, 1);
iterativespreading_accuracies                      = zeros(num_experiments, 1);

for experiment = 1:num_experiments
  train_ind = train_inds{experiment};
  test_ind  = test_inds{experiment};

  num_train = nnz(train_ind);
  num_test  = nnz(test_ind);

%   % Kernel
%   K = K_spreading;
%   cost = spreading_cost;
%   get_svm_accuracy;
%   spreading_accuracies(experiment) = accuracy;

  % Iterative
  probabilities = label_spreading_probability(A, labels, train_ind, test_ind, 'num_iterations', 100, 'alpha', iterativespreading_alpha);
  [~, predictions] = max(probabilities');
  accuracy = mean(predictions' == labels(test_ind));
  iterativespreading_accuracies(experiment) = accuracy;
  

end

fprintf('average performance:\n');

fprintf('iterative spreading                   : %0.3f%%\n', ...
        mean(iterativespreading_accuracies));
    
fprintf('spreading kernel                   : %0.3f%%\n', ...
        mean(spreading_accuracies));
