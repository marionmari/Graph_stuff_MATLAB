function labels = calculate_hashes(features, graph_ind, distance, w)

  % determine path to take depending on chosen distance
  use_cauchy = (strcmpi(distance, 'l1') || strcmpi(distance, 'tv'));
  take_sqrt  = strcmpi(distance, 'hellinger');

  [num_points, d] = size(features);
  num_graphs = max(graph_ind);

  if (take_sqrt)
    features = sqrt(features);
  end

  % generate random projection vector
  v = randn(d, 1);
  if (use_cauchy)
    % if X, Y are N(0, 1), then X / Y has a standard Cauchy distribution
    v = v ./ randn(d, 1);
  end

  % random offset
  b = w * rand;

  % compute hashes
  labels = floor((features * v + b) * (1 / w));
  [~, ~, labels] = unique(labels);

end