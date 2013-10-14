K_train = [(1:numel(train_ind))', K_train];
K_test  = [(1:numel(test_ind))',  K_test];

svm = svmtrain_libsvm(labels(train_ind), K_train, svm_train_options(cost));
[~, accuracy] = svmpredict(labels(test_ind), K_test, svm, svm_test_options);

accuracy = accuracy(1);