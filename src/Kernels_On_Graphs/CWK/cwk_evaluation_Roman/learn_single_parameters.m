num_nodes = size(A, 1);

D          = spdiags(sum(A, 2), 0, num_nodes, num_nodes);
inv_sqrt_D = spdiags(1 ./ sqrt(sum(A, 2)), 0, num_nodes, num_nodes);

L = D - A;
L_hat = inv_sqrt_D * L * inv_sqrt_D;
H = -L;
S = inv_sqrt_D * A * inv_sqrt_D;

A = bsxfun(@times, 1 ./ sum(A, 2), A);

%[num_components, assignments] = graphconncomp(A, 'directed', false);

num_heights = numel(test_heights);
num_betas   = numel(betas);
num_costs   = numel(costs);
num_sigmas  = numel(sigmas);
num_alphas  = numel(alphas);

% 
% % LGC-Kernel (Zhou et al.)   
% average_accuracies = zeros(num_alphas, num_costs);
% for alpha_ind = 1:num_alphas
%   fprintf('alpha: %0.2f\n', alphas(alpha_ind))  
%   K = inv(speye(size(A,1))-alphas(alpha_ind)*S);
% 
%   for i = 1:num_experiments
%     train_ind = train_inds{i};
%     test_ind  = test_inds{i};
% 
%     for cost_ind = 1:num_costs
%       cost = costs(cost_ind);
%       %fprintf('cost: %0.4f\n', cost)
%       get_svm_accuracy;
%       average_accuracies(alpha_ind, cost_ind) = ...
%           average_accuracies(alpha_ind, cost_ind) + accuracy / num_experiments;
%       %fprintf('accuracy: %0.4f\n', accuracy)
%     end
%   end
% end
% 
% [best_average_accuracy, best_ind] = max(average_accuracies(:));
% [best_alpha_ind, best_cost_ind] = ind2sub([num_alphas, num_costs], best_ind);
% 
% spreading_learned_alpha = alphas(best_alpha_ind);
% spreading_learned_cost = costs(best_cost_ind);
% 
% fprintf('spreading best                  : %0.2f%% accuracy, alpha: %0.2f, cost: %0.2f\n', ...
%         best_average_accuracy, ...
%         spreading_learned_alpha, ...
%         spreading_learned_cost);

    
% LGC (Zhou et al.)      
average_accuracies = zeros(num_alphas);
for alpha_ind = 1:num_alphas
  fprintf('alpha: %0.2f\n', alphas(alpha_ind))  

  for i = 1:num_experiments
    train_ind = train_inds{i};
    test_ind  = test_inds{i};

    probabilities = label_spreading_probability(A, labels, train_ind, test_ind, 'num_iterations', 100, 'alpha', alphas(alpha_ind));
    [~, predictions] = max(probabilities');
    accuracy = mean(predictions' == labels(test_ind));
    average_accuracies(alpha_ind) = average_accuracies(alpha_ind) + accuracy / num_experiments;
    
  end
end

[best_average_accuracy, best_ind] = max(average_accuracies(:));
[best_alpha_ind] = ind2sub([num_alphas], best_ind);

iterativespreading_learned_alpha = alphas(best_alpha_ind);

fprintf('spreading best                  : %0.2f%% accuracy, alpha: %0.2f\n', ...
        best_average_accuracy, ...
        iterativespreading_learned_alpha);
    
    
% 
% % CWK
% average_accuracies = zeros(num_alphas, num_heights, num_costs);
% for i = 1:num_experiments
%   train_ind = train_inds{i};
%   test_ind  = test_inds{i};
% 
%   for alpha_ind = 1:num_alphas
%     [K_propagation_train, K_propagation_test] = short_walk_kernel(A, ...
%             labels, train_ind, test_ind, max_walk_length, 'heights', ...
%             test_heights, 'alpha', alphas(alpha_ind));
% 
%     for height_ind = 1:num_heights
%       for cost_ind = 1:num_costs
%         cost = costs(cost_ind);
%         K_train = K_propagation_train(:, :, height_ind);
%         K_test  = K_propagation_test(:, :, height_ind);
%         get_svm_accuracy_propagation;
%         average_accuracies(alpha_ind, height_ind, cost_ind) = ...
%           average_accuracies(alpha_ind, height_ind, cost_ind) + accuracy / num_experiments;
%       end
%     end
%   end
% end
% 
% [best_average_accuracy, best_ind] = max(average_accuracies(:));
% [best_alpha_ind, best_height_ind, best_cost_ind] = ...
%     ind2sub([num_alphas, num_heights, num_costs], best_ind);
% 
% propagation_alpha_learned_alpha       = alphas(best_alpha_ind);
% propagation_alpha_learned_walk_length = test_heights(best_height_ind);
% propagation_alpha_learned_cost        = costs(best_cost_ind);
% 
% fprintf('propagation/na best             : %0.2f%% accuracy, alpha: %0.2f, walk_length: %i, cost: %0.2f\n', ...
%         best_average_accuracy, ...
%         propagation_alpha_learned_alpha, ...
%         propagation_alpha_learned_walk_length, ...
%         propagation_alpha_learned_cost);
% 
% average_accuracies = squeeze(average_accuracies(end, :, :));
% 
% [best_average_accuracy, best_ind] = max(average_accuracies(:));
% [best_height_ind, best_cost_ind] = ind2sub([num_heights, num_costs], best_ind);
% 
% propagation_learned_walk_length = test_heights(best_height_ind);
% propagation_learned_cost        = costs(best_cost_ind);
% 
% fprintf('propagation best                : %0.2f%% accuracy, walk_length: %i, cost: %0.2f\n', ...
%         best_average_accuracy, ...
%         propagation_learned_walk_length, ...
%         propagation_learned_cost);
% 
% % LP 
% average_accuracies = zeros(num_alphas, num_costs);
% for i = 1:num_experiments
%   train_ind = train_inds{i};
%   test_ind  = test_inds{i};
% 
%   for alpha_ind = 1:num_alphas
%     probabilities = label_propagation_probability(A, labels, train_ind, ...
%             (1:num_nodes)', 1000, 'alpha', alphas(alpha_ind));
% 
%     K_lp_train = probabilities(train_ind, :) * probabilities(train_ind, :)';
%     K_lp_test  = probabilities(test_ind, :)  * probabilities(train_ind, :)';
% 
%     for cost_ind = 1:num_costs
%       cost = costs(cost_ind);
%       K_train = K_lp_train;
%       K_test  = K_lp_test;
%       get_svm_accuracy_propagation;
%       average_accuracies(alpha_ind, cost_ind) = ...
%           average_accuracies(alpha_ind, cost_ind) + accuracy / num_experiments;
%     end
%   end
% end
% 
% [best_average_accuracy, best_ind] = max(average_accuracies(:));
% [best_alpha_ind, best_cost_ind] = ind2sub([num_alphas, num_costs], best_ind);
% 
% label_propagation_kernel_alpha_learned_alpha = alphas(best_alpha_ind);
% label_propagation_kernel_alpha_learned_cost  = costs(best_cost_ind);
% 
% fprintf('label propagation kernel/na best: %0.2f%% accuracy, alpha: %0.2f, cost: %0.2f\n', ...
%         best_average_accuracy, ...
%         label_propagation_kernel_alpha_learned_alpha, ...
%         label_propagation_kernel_alpha_learned_cost);
% 
% average_accuracies = average_accuracies(end, :);
% 
% [best_average_accuracy, best_cost_ind] = max(average_accuracies);
% 
% label_propagation_kernel_learned_cost = costs(best_cost_ind);
% 
% fprintf('label propagation kernel best   : %0.2f%% accuracy, cost: %0.2f\n', ...
%         best_average_accuracy, ...
%         label_propagation_kernel_learned_cost);
% 
% % L+
% K = zeros(num_nodes);
% for i = 1:num_components
%   ind = (assignments == i);
%   K(ind, ind) = pinv(full(L_hat(ind, ind)));
% end
% 
% average_accuracies = zeros(num_costs, 1);
% for i = 1:num_experiments
%   train_ind = train_inds{i};
%   test_ind  = test_inds{i};
% 
%   for cost_ind = 1:num_costs
%     cost = costs(cost_ind);
%     get_svm_accuracy;
%     average_accuracies(cost_ind) = average_accuracies(cost_ind) + accuracy / num_experiments;
%   end
% end
% 
% [best_average_accuracy, best_cost_ind] = max(average_accuracies);
% 
% pseudoinverse_learned_cost = costs(best_cost_ind);
% 
% fprintf('pseudoinverse best              : %0.2f%% accuracy, cost: %0.2f\n', ...
%         best_average_accuracy, ...
%         pseudoinverse_learned_cost);
% 
% % DIFF    
% average_accuracies = zeros(num_betas, num_costs);
% for beta_ind = 1:num_betas
%   K = zeros(num_nodes);
%   for i = 1:num_components
%     ind = (assignments == i);
%     K(ind, ind) = expm(betas(beta_ind) * full(H(ind, ind)));
%   end
% 
%   for i = 1:num_experiments
%     train_ind = train_inds{i};
%     test_ind  = test_inds{i};
% 
%     for cost_ind = 1:num_costs
%       cost = costs(cost_ind);
%       get_svm_accuracy;
%       average_accuracies(beta_ind, cost_ind) = ...
%           average_accuracies(beta_ind, cost_ind) + accuracy / num_experiments;
%     end
%   end
% end
% 
% [best_average_accuracy, best_ind] = max(average_accuracies(:));
% [best_beta_ind, best_cost_ind] = ind2sub([num_betas, num_costs], best_ind);
% 
% diffusion_learned_beta = betas(best_beta_ind);
% diffusion_learned_cost = costs(best_cost_ind);
% 
% fprintf('diffusion best                  : %0.2f%% accuracy, beta: %0.2f, cost: %0.2f\n', ...
%         best_average_accuracy, ...
%         diffusion_learned_beta, ...
%         diffusion_learned_cost);
% 
% % regLap    
% average_accuracies = zeros(num_sigmas, num_costs);
% for sigma_ind = 1:num_sigmas
%   K = zeros(num_nodes);
%   for i = 1:num_components
%     ind = (assignments == i);
%     K(ind, ind) = inv(eye(nnz(ind)) + sigmas(sigma_ind)^2 * L_hat(ind, ind));
%   end
% 
%   for i = 1:num_experiments
%     train_ind = train_inds{i};
%     test_ind  = test_inds{i};
% 
%     for cost_ind = 1:num_costs
%       cost = costs(cost_ind);
%       get_svm_accuracy;
%       average_accuracies(sigma_ind, cost_ind) = ...
%           average_accuracies(sigma_ind, cost_ind) + accuracy / num_experiments;
%     end
%   end
% end
% 
% [best_average_accuracy, best_ind] = max(average_accuracies(:));
% [best_sigma_ind, best_cost_ind] = ind2sub([num_sigmas, num_costs], best_ind);
% 
% regularized_laplacian_learned_sigma = sigmas(best_sigma_ind);
% regularized_laplacian_learned_cost  = costs(best_cost_ind);
% 
% fprintf('regularized laplacian best      : %0.2f%% accuracy, sigma: %0.2f, cost: %0.2f\n', ...
%         best_average_accuracy, ...
%         regularized_laplacian_learned_sigma, ...
%         regularized_laplacian_learned_cost);
% 
% if (attributes)
%   K = similarities;
% 
%   average_accuracies = zeros(num_costs, 1);
%   for i = 1:num_experiments
%     train_ind = train_inds{i};
%     test_ind  = test_inds{i};
% 
%     for cost_ind = 1:num_costs
%       cost = costs(cost_ind);
%       get_svm_accuracy;
%       average_accuracies(cost_ind) = ...
%           average_accuracies(cost_ind) + accuracy / num_experiments;
%     end
%   end
% 
%   [best_average_accuracy, best_cost_ind] = max(average_accuracies);
% 
%   attributes_learned_cost = costs(best_cost_ind);
% 
%   fprintf('attributes only best                         : %0.2f%% accuracy, cost: %0.2f\n', ...
%           best_average_accuracy, ...
%           attributes_learned_cost);
% 
%  % ATRIBUTES  
%       
%   average_accuracies = zeros(num_costs, 1);
%   for i = 1:num_experiments
%     train_ind = train_inds{i};
%     test_ind  = test_inds{i};
% 
%     [K_propagation_train, K_propagation_test] = short_walk_kernel(A, ...
%             labels, train_ind, test_ind, propagation_learned_walk_length);
% 
%     K_propagation_train = K_propagation_train + similarities(train_ind, train_ind);
%     K_propagation_test  = K_propagation_test  + similarities(test_ind,  train_ind);
% 
%     for cost_ind = 1:num_costs;
%       cost = costs(cost_ind);
%       K_train = K_propagation_train;
%       K_test  = K_propagation_test;
%       get_svm_accuracy_propagation;
%       average_accuracies(cost_ind) = average_accuracies(cost_ind) + accuracy / num_experiments;
%     end
%   end
% 
%   [best_average_accuracy, best_cost_ind] = max(average_accuracies);
% 
%   propagation_attributes_learned_cost = costs(best_cost_ind);
% 
%   fprintf('propagation + attributes best                : %0.2f%% accuracy, cost: %0.2f\n', ...
%           best_average_accuracy, ...
%           propagation_attributes_learned_cost);
% 
%   average_accuracies = zeros(num_costs, 1);
%   for i = 1:num_experiments
%     train_ind = train_inds{i};
%     test_ind  = test_inds{i};
% 
%     [K_propagation_train, K_propagation_test] = short_walk_kernel(A, ...
%             labels, train_ind, test_ind, propagation_learned_walk_length, ...
%             'alpha', propagation_alpha_learned_alpha);
% 
%     K_propagation_train = K_propagation_train + similarities(train_ind, train_ind);
%     K_propagation_test  = K_propagation_test  + similarities(test_ind,  train_ind);
% 
%     for cost_ind = 1:num_costs;
%       cost = costs(cost_ind);
%       K_train = K_propagation_train;
%       K_test  = K_propagation_test;
%       get_svm_accuracy_propagation;
%       average_accuracies(cost_ind) = average_accuracies(cost_ind) + accuracy / num_experiments;
%     end
%   end
% 
%   [best_average_accuracy, best_cost_ind] = max(average_accuracies);
% 
%   propagation_alpha_attributes_learned_cost = costs(best_cost_ind);
% 
%   fprintf('propagation/na + attributes best             : %0.2f%% accuracy, cost: %0.2f\n', ...
%           best_average_accuracy, ...
%           propagation_alpha_attributes_learned_cost);
% 
%   average_accuracies = zeros(num_costs, 1);
%   for i = 1:num_experiments
%     train_ind = train_inds{i};
%     test_ind  = test_inds{i};
% 
%     probabilities = label_propagation_probability(A, labels, train_ind, (1:num_nodes)', 1000);
% 
%     K_lp_train = probabilities(train_ind, :) * probabilities(train_ind, :)';
%     K_lp_test  = probabilities(test_ind, :)  * probabilities(train_ind, :)';
% 
%     K_lp_train = K_lp_train + similarities(train_ind, train_ind);
%     K_lp_test  = K_lp_test  + similarities(test_ind,  train_ind);
% 
%     for cost_ind = 1:num_costs;
%       cost = costs(cost_ind);
%       K_train = K_lp_train;
%       K_test  = K_lp_test;
%       get_svm_accuracy_propagation;
%       average_accuracies(cost_ind) = average_accuracies(cost_ind) + accuracy / num_experiments;
%     end
%   end
% 
%   [best_average_accuracy, best_cost_ind] = max(average_accuracies);
% 
%   label_propagation_kernel_attributes_learned_cost = costs(best_cost_ind);
% 
%   fprintf('label propagation kernel + attributes best   : %0.2f%% accuracy, cost: %0.2f\n', ...
%           best_average_accuracy, ...
%           label_propagation_kernel_attributes_learned_cost);
% 
%   average_accuracies = zeros(num_costs, 1);
%   for i = 1:num_experiments
%     train_ind = train_inds{i};
%     test_ind  = test_inds{i};
% 
%     probabilities = label_propagation_probability(A, labels, train_ind, ...
%             (1:num_nodes)', 1000, 'alpha', label_propagation_kernel_alpha_learned_alpha);
% 
%     K_lp_train = probabilities(train_ind, :) * probabilities(train_ind, :)';
%     K_lp_test  = probabilities(test_ind, :)  * probabilities(train_ind, :)';
% 
%     K_lp_train = K_lp_train + similarities(train_ind, train_ind);
%     K_lp_test  = K_lp_test  + similarities(test_ind,  train_ind);
% 
%     for cost_ind = 1:num_costs;
%       cost = costs(cost_ind);
%       K_train = K_lp_train;
%       K_test  = K_lp_test;
%       get_svm_accuracy_propagation;
%       average_accuracies(cost_ind) = average_accuracies(cost_ind) + accuracy / num_experiments;
%     end
%   end
% 
%   [best_average_accuracy, best_cost_ind] = max(average_accuracies);
% 
%   label_propagation_kernel_alpha_attributes_learned_cost = costs(best_cost_ind);
% 
%   fprintf('label propagation kernel/na + attributes best: %0.2f%% accuracy, cost: %0.2f\n', ...
%           best_average_accuracy, ...
%           label_propagation_kernel_alpha_attributes_learned_cost);
% 
%   K = expm(diffusion_learned_beta * H);
%   K = similarities + K / max(K(:));
% 
%   average_accuracies = zeros(num_costs, 1);
%   for i = 1:num_experiments
%     train_ind = train_inds{i};
%     test_ind  = test_inds{i};
% 
%     for cost_ind = 1:num_costs;
%       cost = costs(cost_ind);
%       get_svm_accuracy;
%       average_accuracies(cost_ind) = average_accuracies(cost_ind) + accuracy / num_experiments;
%     end
%   end
% 
%   [best_average_accuracy, best_cost_ind] = max(average_accuracies);
% 
%   diffusion_attributes_learned_cost = costs(best_cost_ind);
% 
%   fprintf('diffusion + attributes best                  : %0.2f%% accuracy, cost: %0.2f\n', ...
%           best_average_accuracy, ...
%           diffusion_attributes_learned_cost);
% 
%   K = zeros(num_nodes);
%   for i = 1:num_components
%     ind = (assignments == i);
%     K(ind, ind) = pinv(full(L_hat(ind, ind)));
%   end
%   K = similarities + K / max(K(:));
% 
%   average_accuracies = zeros(num_costs, 1);
%   for i = 1:num_experiments
%     train_ind = train_inds{i};
%     test_ind  = test_inds{i};
% 
%     for cost_ind = 1:num_costs
%       cost = costs(cost_ind);
%       get_svm_accuracy;
%       average_accuracies(cost_ind) = average_accuracies(cost_ind) + accuracy / num_experiments;
%     end
%   end
% 
%   [best_average_accuracy, best_cost_ind] = max(average_accuracies);
% 
%   pseudoinverse_attributes_learned_cost = costs(best_cost_ind);
% 
%   fprintf('pseudoinverse + attributes best              : %0.2f%% accuracy, cost: %0.2f\n', ...
%           best_average_accuracy, ...
%           pseudoinverse_attributes_learned_cost);
% 
%   K = zeros(num_nodes);
%   for i = 1:num_components
%     ind = (assignments == i);
%     K(ind, ind) = inv(eye(nnz(ind)) + regularized_laplacian_learned_sigma^2 * L_hat(ind, ind));
%   end
%   K = similarities + K / max(K(:));
% 
%   average_accuracies = zeros(num_costs, 1);
%   for i = 1:num_experiments
%     train_ind = train_inds{i};
%     test_ind  = test_inds{i};
% 
%     for cost_ind = 1:num_costs
%       cost = costs(cost_ind);
%       get_svm_accuracy;
%       average_accuracies(cost_ind) = average_accuracies(cost_ind) + accuracy / num_experiments;
%     end
%   end
% 
%   [best_average_accuracy, best_cost_ind] = max(average_accuracies);
% 
%   regularized_laplacian_attributes_learned_cost = costs(best_cost_ind);
% 
%   fprintf('regularized laplacian + attributes best      : %0.2f%% accuracy, cost: %0.2f\n', ...
%           best_average_accuracy, ...
%           regularized_laplacian_attributes_learned_cost);
% end
