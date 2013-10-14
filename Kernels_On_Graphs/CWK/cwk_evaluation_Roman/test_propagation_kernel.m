num_nodes         = size(A, 1);
num_heights       = numel(test_heights);
num_alpha_heights = numel(alpha_test_heights);

propagation_accuracies                    = zeros(num_experiments, num_heights);
best_propagation_accuracies               = zeros(num_experiments, 1);
propagation_alpha_accuracies              = zeros(num_experiments, num_alpha_heights);
best_propagation_alpha_accuracies         = zeros(num_experiments, 1);
label_propagation_kernel_accuracies       = zeros(num_experiments, 1);
label_propagation_kernel_alpha_accuracies = zeros(num_experiments, 1);
label_propagation_accuracies              = zeros(num_experiments, 1);
diffusion_accuracies                      = zeros(num_experiments, 1);
pseudoinverse_accuracies                  = zeros(num_experiments, 1);
regularized_laplacian_accuracies          = zeros(num_experiments, 1);

if (attributes)
  propagation_attributes_accuracies                    = zeros(num_experiments, num_heights);
  best_propagation_attributes_accuracies               = zeros(num_experiments, 1);
  propagation_alpha_attributes_accuracies              = zeros(num_experiments, num_alpha_heights);
  best_propagation_alpha_attributes_accuracies         = zeros(num_experiments, 1);
  label_propagation_kernel_attributes_accuracies       = zeros(num_experiments, 1);
  label_propagation_kernel_alpha_attributes_accuracies = zeros(num_experiments, 1);
  label_propagation_attributes_accuracies              = zeros(num_experiments, 1);
  diffusion_attributes_accuracies                      = zeros(num_experiments, 1);
  pseudoinverse_attributes_accuracies                  = zeros(num_experiments, 1);
  regularized_laplacian_attributes_accuracies          = zeros(num_experiments, 1);
end

for experiment = 1:num_experiments
  train_ind = train_inds{experiment};
  test_ind  = test_inds{experiment};

  num_train = nnz(train_ind);
  num_test  = nnz(test_ind);

  [K_propagation_train, K_propagation_test] = short_walk_kernel(A, ...
          labels, train_ind, test_ind, walk_length, 'heights', test_heights);

  for i = 1:num_heights
    K_train = K_propagation_train(:, :, i);
    K_test  = K_propagation_test(:, :, i);
    cost = propagation_cost;
    get_svm_accuracy_propagation;
    propagation_accuracies(experiment, i) = accuracy;

    if (attributes)
      K_train = K_propagation_train(:, :, i);
      K_test  = K_propagation_test(:, :, i);
      K_train = K_train + similarities(train_ind, train_ind);
      K_test  = K_test  + similarities(test_ind,  train_ind);
      cost = propagation_attributes_cost;
      get_svm_accuracy_propagation;
      propagation_attributes_accuracies(experiment, i) = accuracy;
    end
  end

  best_propagation_accuracies(experiment) = max(propagation_accuracies(experiment, :));
  if (attributes)
    best_propagation_attributes_accuracies(experiment) = max(propagation_attributes_accuracies(experiment, :));
  end

  [K_propagation_train, K_propagation_test] = short_walk_kernel(A, ...
          labels, train_ind, test_ind, alpha_walk_length, 'heights', ...
          alpha_test_heights, 'alpha', propagation_alpha);

  for i = 1:num_alpha_heights
    K_train = K_propagation_train(:, :, i);
    K_test  = K_propagation_test(:, :, i);
    cost = propagation_alpha_cost;
    get_svm_accuracy_propagation;
    propagation_alpha_accuracies(experiment, i) = accuracy;
    if (attributes)
      K_train = K_propagation_train(:, :, i);
      K_test  = K_propagation_test(:, :, i);
      K_train = K_train + similarities(train_ind, train_ind);
      K_test  = K_test  + similarities(test_ind,  train_ind);
      cost = propagation_alpha_attributes_cost;
      get_svm_accuracy_propagation;
      propagation_alpha_attributes_accuracies(experiment, i) = accuracy;
    end
  end

  best_propagation_alpha_accuracies(experiment) = max(propagation_alpha_accuracies(experiment, :));
  if (attributes)
    best_propagation_alpha_attributes_accuracies(experiment) = max(propagation_alpha_attributes_accuracies(experiment, :));
  end

  probabilities = label_propagation_probability(A, labels, train_ind, (1:num_nodes)', 1000);

  [~, label_propagation_predictions] = max(probabilities(test_ind, :), [], 2);
  label_propagation_accuracies(experiment) = ...
      100 * mean(label_propagation_predictions == labels(test_ind));

  K_train = probabilities(train_ind, :) * probabilities(train_ind, :)';
  K_test  = probabilities(test_ind, :)  * probabilities(train_ind, :)';
  cost = label_propagation_kernel_cost;
  get_svm_accuracy_propagation;
  label_propagation_kernel_accuracies(experiment) = accuracy;

  if (attributes)
    K_train = probabilities(train_ind, :) * probabilities(train_ind, :)';
    K_test  = probabilities(test_ind, :)  * probabilities(train_ind, :)';
    K_train = K_train + similarities(train_ind, train_ind);
    K_test  = K_test  + similarities(test_ind,  train_ind);
    cost = propagation_attributes_cost;
    get_svm_accuracy_propagation;
    label_propagation_kernel_attributes_accuracies(experiment, i) = accuracy;
  end

  probabilities = label_propagation_probability(A, labels, train_ind, ...
          (1:num_nodes)', 1000, 'alpha', label_propagation_kernel_alpha);

  K_train = probabilities(train_ind, :) * probabilities(train_ind, :)';
  K_test  = probabilities(test_ind, :)  * probabilities(train_ind, :)';
  cost = label_propagation_kernel_alpha_cost;
  get_svm_accuracy_propagation;
  label_propagation_kernel_alpha_accuracies(experiment) = accuracy;

  if (attributes)
    K_train = probabilities(train_ind, :) * probabilities(train_ind, :)';
    K_test  = probabilities(test_ind, :)  * probabilities(train_ind, :)';
    K_train = K_train + similarities(train_ind, train_ind);
    K_test  = K_test  + similarities(test_ind,  train_ind);
    cost = propagation_alpha_attributes_cost;
    get_svm_accuracy_propagation;
    label_propagation_kernel_alpha_attributes_accuracies(experiment, i) = accuracy;
  end

  K = K_diffusion;
  cost = diffusion_cost;
  get_svm_accuracy;
  diffusion_accuracies(experiment) = accuracy;

  if (attributes)
    K = K_diffusion / max(K_diffusion(:)) + similarties;
    cost = diffusion_attributes_cost;
    get_svm_accuracy;
    diffusion_attributes_accuracies(experiment) = accuracy;
  end

  K = K_pseudoinverse;
  cost = pseudoinverse_cost;
  get_svm_accuracy;
  pseudoinverse_accuracies(experiment) = accuracy;

  if (attributes)
    K = K_pseudoinverse / max(K_pseudoinverse(:)) + similarties;
    cost = pseudoinverse_attributes_cost;
    get_svm_accuracy;
    pseudoinverse_attributes_accuracies(experiment) = accuracy;
  end

  K = K_regularized_laplacian;
  cost = regularized_laplacian_cost;
  get_svm_accuracy;
  regularized_laplacian_accuracies(experiment) = accuracy;

  if (attributes)
    K = K_regularized_laplacian / max(K_regularized_laplacian(:)) + similarties;
    cost = regularized_laplacian_attributes_cost;
    get_svm_accuracy;
    regularized_laplacian_attributes_accuracies(experiment) = accuracy;
  end
end

fprintf('average performance:\n');
fprintf('propagation (learned height)       : %0.2f%%\n', ...
        mean(propagation_accuracies(:, propagation_best_ind)));
fprintf('propagation (best height)          : %0.2f%%\n', ...
        mean(best_propagation_accuracies));
fprintf('propagation alpha (learned height) : %0.2f%%\n', ...
        mean(propagation_alpha_accuracies(:, propagation_alpha_best_ind)));
fprintf('propagation alpha (best height)    : %0.2f%%\n', ...
        mean(best_propagation_alpha_accuracies));
fprintf('label propagation                  : %0.2f%%\n', ...
        mean(label_propagation_accuracies));
fprintf('label propagation kernel           : %0.2f%%\n', ...
        mean(label_propagation_kernel_accuracies));
fprintf('label propagation kernel alpha     : %0.2f%%\n', ...
        mean(label_propagation_kernel_alpha_accuracies));
fprintf('diffusion kernel                   : %0.2f%%\n', ...
        mean(diffusion_accuracies));
fprintf('pseudoinverse                      : %0.2f%%\n', ...
        mean(pseudoinverse_accuracies));
fprintf('regularized laplacian              : %0.2f%%\n', ...
        mean(regularized_laplacian_accuracies));
if (attributes)
  fprintf('with attributes:\n');
  fprintf('propagation (learned height)       : %0.2f%%\n', ...
          mean(propagation_attributes_accuracies(:, propagation_best_ind)));
  fprintf('propagation (best height)          : %0.2f%%\n', ...
          mean(best_propagation_attributes_accuracies));
  fprintf('propagation alpha (learned height) : %0.2f%%\n', ...
          mean(propagation_alpha_attributes_accuracies(:, propagation_alpha_best_ind)));
  fprintf('propagation alpha (best height)    : %0.2f%%\n', ...
          mean(best_propagation_alpha_attributes_accuracies));
  fprintf('label propagation                  : %0.2f%%\n', ...
          mean(label_propagation_attributes_accuracies));
  fprintf('label propagation kernel           : %0.2f%%\n', ...
          mean(label_propagation_kernel_attributes_accuracies));
  fprintf('label propagation kernel alpha     : %0.2f%%\n', ...
          mean(label_propagation_kernel_alpha_attributes_accuracies));
  fprintf('diffusion kernel                   : %0.2f%%\n', ...
          mean(diffusion_attributes_accuracies));
  fprintf('pseudoinverse                      : %0.2f%%\n', ...
          mean(pseudoinverse_attributes_accuracies));
  fprintf('regularized laplacian              : %0.2f%%\n', ...
          mean(regularized_laplacian_attributes_accuracies));
end