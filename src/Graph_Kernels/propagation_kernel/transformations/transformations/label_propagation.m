function features = label_propagation(features, A, train_ind, ...
          observed_labels)

  num_train   = numel(observed_labels);
  num_classes = size(features, 2);

  features = A * features;

  % "push back" training labels
  features(train_ind, :) = ...
      accumarray([(1:num_train)', observed_labels], 1, ...
                 [num_train, num_classes]);

end