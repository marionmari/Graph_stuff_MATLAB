function features = prior_label_distributions(A, train_ind, ...
          observed_labels, num_classes)

  num_nodes = size(A, 1);
  num_train = numel(train_ind);

  features = repmat(ones(1, num_classes) / num_classes, [num_nodes, 1]);

  % place delta distributions on known labels
  features(train_ind, :) = ...
      accumarray([(1:num_train)', observed_labels], 1, ...
                 [num_train, num_classes]);

end