K_train = [(1:numel(train_ind))', K(train_ind, train_ind)];
K_test  = [(1:numel(test_ind))',  K(test_ind,  train_ind)];

svm = svmtrain_libsvm(labels(train_ind), K_train, svm_train_options(cost));
predictions = svmpredict(labels(test_ind), K_test, svm, svm_test_options);

% accuracy = accuracy(1);
accuracy = mean(predictions == labels(test_ind));