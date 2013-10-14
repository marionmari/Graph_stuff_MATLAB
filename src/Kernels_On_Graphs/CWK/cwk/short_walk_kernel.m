function [K_train, K_test] = short_walk_kernel(A, labels, lp_train_ind, train_ind, ...
          test_ind, walk_length, varargin)

  options = inputParser;
  options.addParamValue('use_prior', false, ...
                        @(x) (islogical(x) && (numel(x) == 1)));
  options.addParamValue('pseudocount', 0.1, ...
                        @(x) (isscalar(x) && (x > 0)));
  options.addParamValue('heights', walk_length, ...
                        @(x) (isnumeric(x) && all(x >= 0)));
  options.addParamValue('alpha', 1, ...
                        @(x) (isscalar(x) && (x >= 0) && (x <= 1)));

  options.parse(varargin{:});
  options = options.Results;

  num_nodes = size(A, 1);
  num_train = numel(train_ind);
  num_test  = numel(test_ind);

  probabilities = label_propagation_probability(A, labels, lp_train_ind, (1:num_nodes)', ...
          walk_length, ...
          'use_prior', options.use_prior, ...
          'pseudocount', options.pseudocount, ...
          'alpha', options.alpha, ...
          'store_intermediate', true);
  
  current_K_train = zeros(num_train, num_train);
  current_K_test  = zeros(num_test,  num_train);
  
  K_train = zeros(num_train, num_train, numel(options.heights));
  K_test  = zeros(num_test,  num_train, numel(options.heights));

  height_ind = 1;
  for i = 1:(walk_length + 1)
    current_K_train = current_K_train + ...
        probabilities(train_ind, :, i) * probabilities(train_ind, :, i)';
    current_K_test  = current_K_test  + ...
        probabilities(test_ind, :, i)  * probabilities(train_ind, :, i)';

    if (ismember(i - 1, options.heights))
      K_train(:, :, height_ind) = current_K_train / i;
      K_test( :, :, height_ind) = current_K_test  / i;
      height_ind = height_ind + 1;
    end
  end
end