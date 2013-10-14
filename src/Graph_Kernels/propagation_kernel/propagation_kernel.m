function K = propagation_kernel(A, graph_ind, labels, train_ind, ...
                                max_height, w, use_cauchy, use_pushback, ...
                                take_sum, labels_1)
  
  graph_ind = double(graph_ind);
  labels = double(labels);

  % row-normalize adjacency matrix!
  if find(sum(A,1)~=1)
      A = bsxfun(@times, A, 1./sum(A,2));  
  end

  
  num_nodes   = size(A, 1);
  num_graphs  = max(graph_ind);
  num_classes = double(max(labels));
  num_train   = numel(train_ind);
 

  % calculate and store the rows of the probability matrix
  % corresponding to the training nodes
  train_rows = accumarray([(1:num_train)', double(labels(train_ind))], 1, ...
                          [num_train, num_classes]);
              
                      
  % initialize the probability matrix, using a uniform distribution
  % on the unlabeled nodes
  probabilities = (1 / num_classes) * ones(num_nodes, num_classes);
  probabilities(train_ind, :) = train_rows;

  
  if (nargin == 10)
      labels_1 = double(labels_1);
      num_classes_1 = double(max(labels_1));
      train_rows_1 = accumarray([(1:num_train)', double(labels_1(train_ind))], 1, ...
                     [num_train, num_classes_1]);
      
      probabilities_1 = (1 / num_classes_1) * ones(num_nodes, num_classes_1);
      probabilities_1(train_ind, :) = train_rows_1;
  end
  
  % initialize output array
  if (take_sum)
    K = zeros(num_graphs);
  else
    K = zeros(num_graphs, num_graphs, max_height + 1);
  end

  height = 0;
  while (true)

    % calculate the kernel contribution at this height
    if (nargin == 10)
        contribution = propagation_kernel_contribution([probabilities_1(:,1:end-1) probabilities], ...
                graph_ind, w, use_cauchy);
    else
        contribution = propagation_kernel_contribution(probabilities, ...
                graph_ind, w, use_cauchy);
    end
        
    contribution = contribution + contribution' - diag(diag(contribution));

    if (take_sum)
      K = K + contribution;
    else
      K(:, :, height + 1) = contribution;
    end

    % avoid updating probabilities after the last contribution
    if (height == max_height)
      break;
    end

    % update probabilities
    probabilities = A * probabilities;
    if (nargin == 10)
      probabilities_1 = A * probabilities_1;
    end

    % push back labels if desired
    if (use_pushback)
      probabilities(train_ind, :) = train_rows;
      if (nargin == 10)
        probabilities_1(train_ind, :) = train_rows_1;
      end
    end

    height = height + 1;
  end
end