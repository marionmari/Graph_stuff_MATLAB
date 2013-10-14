use_prior                           = false;
pseudocount                         = 1;
walk_length                         = propagation_learned_walk_length * 2;
propagation_cost                    = propagation_learned_cost;
alpha_walk_length                   = propagation_alpha_learned_walk_length * 2;
propagation_alpha                   = propagation_alpha_learned_alpha;
propagation_alpha_cost              = propagation_alpha_learned_cost;
label_propagation_kernel_cost       = label_propagation_kernel_learned_cost;
label_propagation_kernel_alpha      = label_propagation_kernel_alpha_learned_alpha;
label_propagation_kernel_alpha_cost = label_propagation_kernel_alpha_learned_cost;
beta                                = diffusion_learned_beta;
diffusion_cost                      = diffusion_learned_cost;
regularized_laplacian_sigma         = regularized_laplacian_learned_sigma;
regularized_laplacian_cost          = regularized_laplacian_learned_cost;
pseudoinverse_cost                  = pseudoinverse_learned_cost;
spreading_cost                      = spreading_learned_cost;
spreading_alpha                     = spreading_learned_alpha;

if (attributes)
  attributes_cost                          = attributes_learned_cost;
  propagation_attributes_cost              = propagation_attributes_learned_cost;
  label_propagation_kernel_attributes_cost = label_propagation_kernel_attributes_learned_cost;
  diffusion_attributes_cost                = diffusion_attributes_learned_cost;
end

if (walk_length >= 20)
  test_heights = [0 0:10:walk_length];
else
  test_heights = 0:walk_length;
end

if (alpha_walk_length >= 20)
  alpha_test_heights = [0 10:10:alpha_walk_length];
else
  alpha_test_heights = 0:alpha_walk_length;
end

propagation_best_ind       = find(test_heights       == propagation_learned_walk_length);
propagation_alpha_best_ind = find(alpha_test_heights == propagation_alpha_learned_walk_length);