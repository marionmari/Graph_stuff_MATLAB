max_walk_length = 200;
use_prior       = false;
pseudocount     = 1;
test_heights    = [0:10 20:10:max_walk_length];
attributes      = false;
train_fractions = [0.1];
problems        = {'dblp', 'webkb', 'cora', 'citeseer', ...
                   'populated_places_1000', 'populated_places_2000', ...
                   'populated_places_5000'};
num_experiments = 10;

% diffusion
betas  = 2.^(-4:7);
% svm
costs  = 2.^(-4:7);
% regularized laplacian
sigmas = 2.^(-4:7);
% cwk, spreading kernel
alphas = [0.05, 0.1, 0.2, 0.5, 0.8, 0.9, 0.95];%[0, 0.05, 0.1, 0.2, 0.5, 0.8, 0.9, 0.95];

svm_train_options = @(cost) (['-q -t 4 -c ' num2str(cost)]);
svm_test_options  = '-q';

data_directory    = '/Users/marion/workspace/workspace_main/MarkovLogicSets/src/PropagationKernels/tmp_files/data/';  %'~/work/experiments/short_walk_kernel/datasets/';
splits_directory  = '/Users/marion/workspace/workspace_main/MarkovLogicSets/src/PropagationKernels/tmp_files/folds_training/';  %'~/work/experiments/short_walk_kernel/splits/training/';
results_directory = '/Users/marion/workspace/workspace_main/MarkovLogicSets/src/PropagationKernels/tmp_files/prelearned_parameters/';  %'~/work/results/short_walk_kernel/learned_parameters/';

variables_to_save = {'*learned*', 'betas', 'costs', 'alphas', 'sigmas', ...
                    'test_heights', 'test_inds', 'train_inds'};

for train_fraction = train_fractions
  for problem = problems
    filename = problem{:};
    load([data_directory filename]);
    if train_fraction == 0.05
        tmp = load([splits_directory filename '_training_splits.mat']);
    else
        tmp = load([splits_directory filename '_training_splits_' num2str(train_fraction) '.mat']);
    end
    train_inds = tmp.train_inds;
    test_inds = tmp.test_inds;
    
    fprintf('learning parameters for %s ...\n', filename);
    learn_single_parameters;
    save([results_directory filename '_learned_parameters_' num2str(train_fraction) '.mat'], variables_to_save{:}, '-append');
  end
end