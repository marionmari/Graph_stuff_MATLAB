% An implementation of the coinciding walk kernel (CWK) described in:
%
%   Neumann, M., Garnett, R., and Kersting, K. Coinciding Walk
%   Kernels: Parallel Absorbing Random Walks for Learning with Graphs
%   and Few Labels. (2013). To appear in: Proceedings of the 5th
%   Annual Asian Conference on Machine Learning (ACML 2013).
%
% function [K_train, K_test] = coinciding_walk_kernel(A, train_ind, ...
%           observed_labels, test_ind, num_classes, walk_length, varargin)
%
% required inputs:
%                 A: the adjacency matrix for the graph under
%                    consideration
%         train_ind: a list of indices into A comprising the
%                    training nodes
%   observed_labels: a list of integer labels corresponding to the
%                    nodes in train_ind
%          test_ind: a list of indices into A comprising the test
%                    nodes
%      num_classses: the number of classes
%       walk_length: the maximum walk length for the CWK
%
% optional named arguments specified after requried inputs:
%           'alpha': the absorbtion parameter to use in [0, 1]
%                    (default: 1)
%    'walk_lengths': the set of walk lengths for which to report
%                    the CWK.  this can save computation if
%                    multiple walk lengths are to be compared.
%                    (default: {walk_length})
%   'uniform_prior': a boolean indicating whether to use a uniform
%                    prior (true) or the empirical distribution on
%                    the training points (false) as the prior
%                    (default: true)
%     'pseudocount': if uniform_prior is set to false, a per-class
%                    pseudocount can also be specified.
%                    (default: 1)
%
% outputs:
%   K_train: the set of (train x train) kernel matrices.
%            K_train(:, :, i) corresponds to the ith largest
%            specified walk length.
%    K_test: the set of (train x test) kernel matrices.
%            K_test(:, :, i) corresponds to the ith largest
%            specified walk length.
%
% Copyright (c) 2013, Roman Garnett (romangarnett@gmail.com)

function [K_train, K_test] = coinciding_walk_kernel(A, train_ind, ...
          observed_labels, test_ind, num_classes, walk_length, varargin)

  options = inputParser;

  options.addParamValue('alpha', 1, ...
                        @(x) (isscalar(x) && (x >= 0) && (x <= 1)));
  options.addParamValue('walk_lengths', walk_length, ...
                        @(x) (isnumeric(x) && all(x >= 0) && all(x <= walk_length)));
  options.addParamValue('uniform_prior', true, ...
                        @(x) (islogical(x) && (numel(x) == 1)));
  options.addParamValue('pseudocount', 1, ...
                        @(x) (isscalar(x) && (x > 0)));

  options.parse(varargin{:});
  options = options.Results;

  % ensure walk lengths are sorted for compatability with ismembc
  % function
  options.walk_lengths = sort(options.walk_lengths);
  num_walk_lengths = numel(options.walk_lengths);

  num_nodes = size(A, 1);
  num_train = numel(train_ind);
  num_test  = numel(test_ind);

  % initialize label prior
  if (options.uniform_prior)
    prior = ones(1, num_classes) / num_classes;
  else
    % use empirical distribution with Dirichlet smoothing
    prior = options.pseudocount * ones(1, num_classes) + ...
            accumarray(observed_labels, 1, [num_classes, 1])';
  end

  % extend graph with special "label" nodes; see paper for details
  A = [A, zeros(num_nodes, num_classes); ...
       zeros(num_classes, num_nodes + num_classes)];

  A(train_ind, :) = (1 - options.alpha) * A(train_ind, :);

  A = A + sparse(train_ind, num_nodes + observed_labels, options.alpha, ...
                 num_nodes + num_classes, num_nodes + num_classes);

  pseudo_train_ind = (num_nodes + 1):(num_nodes + num_classes);
  A(pseudo_train_ind, pseudo_train_ind) = speye(num_classes);

  % initialize probabilities
  probabilities = repmat(prior, [num_nodes + num_classes, 1]);
  probabilities(train_ind, :) = ...
      accumarray([(1:num_train)', observed_labels], 1, [num_train, num_classes]);
  probabilities(pseudo_train_ind, :) = eye(num_classes);

  current_K_train = zeros(num_train, num_train);
  current_K_test  = zeros(num_test,  num_train);

  K_train = zeros(num_train, num_train, num_walk_lengths);
  K_test  = zeros(num_test,  num_train, num_walk_lengths);

  iteration = 0;
  walk_length_ind = 1;
  while (true)
    % update running total
    current_K_train = current_K_train + ...
        probabilities(train_ind, :) * probabilities(train_ind, :)';
    current_K_test  = current_K_test  + ...
        probabilities(test_ind, :)  * probabilities(train_ind, :)';

    % check whether current iteration is desired walk length and
    % store if necessary
    if (ismembc(iteration, options.walk_lengths))
      K_train(:, :, walk_length_ind) = (1 / (iteration + 1)) * current_K_train;
      K_test( :, :, walk_length_ind) = (1 / (iteration + 1)) * current_K_test;
      walk_length_ind = walk_length_ind + 1;
    end

    % no need to perform final propagation
    if (iteration == walk_length)
      break;
    end

    probabilities = A * probabilities;

    iteration = iteration + 1;
  end

end