function K = short_walk_kernel_full(A, labels, train_ind, ...
          walk_length, varargin)

  labels = double(labels);
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

  probabilities = label_propagation_probability(A, labels, train_ind, (1:num_nodes)', ...
          walk_length, ...
          'use_prior', options.use_prior, ...
          'pseudocount', options.pseudocount, ...
          'alpha', options.alpha, ...
          'store_intermediate', true);

  current_K = zeros(num_nodes);
  K = zeros(num_nodes, num_nodes, numel(options.heights));

  height_ind = 1;
  for i = 1:(walk_length + 1)
    current_K = current_K + ...
        probabilities(:, :, i) * probabilities(:, :, i)';

    if (ismember(i - 1, options.heights))
      K(:, :, height_ind) = current_K / i;
      height_ind = height_ind + 1;
    end
  end
end