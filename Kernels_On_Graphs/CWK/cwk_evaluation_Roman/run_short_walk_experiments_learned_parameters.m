problems = {'dblp'};
% problems = {'webkb', 'dblp', 'cora', 'citeseer', ...
%             'populated_places_1000', 'populated_places_2000', ...
%             'populated_places_5000'};

learned_train_fraction = 0.05;
train_fractions        = 0.05;%0.01:0.01:0.07;%0.08:0.01:0.15;
% learned_train_fraction = 0.1;
% train_fractions        = 0.1;%0.08:0.01:0.15;


num_experiments        = 20;
attributes             = false;

svm_train_options = @(cost) (['-q -t 4 -c ' num2str(cost)]);
svm_test_options  = '-q';



data_directory    = '/Users/marion/workspace/workspace_main/MarkovLogicSets/src/PropagationKernels/tmp_files/data/';  %'~/work/experiments/short_walk_kernel/datasets/';
splits_directory  = '/Users/marion/workspace/workspace_main/MarkovLogicSets/src/PropagationKernels/tmp_files/folds/';  %'~/work/experiments/short_walk_kernel/splits/training/';
parameters_directory = '/Users/marion/workspace/workspace_main/MarkovLogicSets/src/PropagationKernels/tmp_files/prelearned_parameters/';  %'~/work/results/short_walk_kernel/learned_parameters/';
results_directory    = '/Users/marion/workspace/workspace_main/MarkovLogicSets/src/PropagationKernels/tmp_files/results_PK/';


variables_to_load = {'*learned*'};
variables_to_save = {'*accuracies', 'test_heights', 'alpha_test_heights', ...
                    'train_fractions'};
variables_to_save_SPREAD = {'*accuracies', 'train_fractions'};

for problem = problems
  filename = problem{:};
  load([data_directory filename]);
  load([parameters_directory filename '_learned_parameters_' ...
        num2str(learned_train_fraction) '.mat'], variables_to_load{:});
  spreading_cost  = spreading_learned_cost;
  spreading_alpha = spreading_learned_alpha;
  iterativespreading_alpha = iterativespreading_learned_alpha;
  %set_learned_parameters;
  %precompute_kernels;
  for train_fraction = train_fractions
    fprintf('testing %s with %i%% training data ...\n', filename, ...
            round(train_fraction * 100));
    load([splits_directory filename '_testing_splits_' num2str(train_fraction) '.mat']);
    test_spreading_kernel;
    save([results_directory filename '_' num2str(train_fraction) '.mat'], variables_to_save_SPREAD{:});
    %test_propagation_kernel;
    %save([results_directory filename '_' num2str(train_fraction) '.mat'], variables_to_save{:});
  end
end
