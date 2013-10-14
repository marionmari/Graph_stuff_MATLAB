% copyright (c) roman garnett, 2011--2012

function probabilities = label_spreading_probability(A, labels, ...
          train_ind, test_ind, varargin)

  options = inputParser;

  options.addParamValue('use_prior', false, ...
                        @(x) (islogical(x) && (numel(x) == 1)));
  options.addParamValue('pseudocount', 1, ...
                        @(x) (isscalar(x) && (x > 0)));
  options.addParamValue('num_iterations', 100, ...
                        @(x) (isscalar(x) && (x > 0)));
  options.addParamValue('alpha', 0.99, ...
                        @(x) (isscalar(x) && (x >= 0) && (x <= 1)));

  options.parse(varargin{:});
  options = options.Results;

  num_nodes   = size(A, 1);
  num_classes = max(labels);
  num_train   = numel(train_ind);

  D = full(1 ./ sqrt(sum(A)));
  A = bsxfun(@times, D, bsxfun(@times, A, D'));

  if (options.use_prior)
    prior = options.pseudocount * ones(1, num_classes) + ...
            accumarray(labels(train_ind), 1, [1, num_classes]);
    prior = prior / sum(prior);
  else
    prior = ones(1, num_classes) / num_classes;
  end

  % preallocate the rows in the label probability matrix for the
  % labeled nodes
  train_rows = accumarray([(1:num_train)', labels(train_ind)], 1, ...
                          [num_train, num_classes]);

  initial_probabilities = repmat(prior, [num_nodes, 1]);
  initial_probabilities(train_ind, :) = train_rows;

  probabilities = zeros(num_nodes, num_classes);
  for i = 1:options.num_iterations
    probabilities = options.alpha  * A * probabilities + ...
               (1 - options.alpha) * initial_probabilities;
  end

  probabilities = probabilities(test_ind, :);
end