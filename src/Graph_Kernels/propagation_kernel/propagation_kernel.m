function K = propagation_kernel(features, graph_ind, transformation, ...
                                num_iterations, varargin)

  verbose = true;
                            
  options = inputParser;

  options.addOptional('distance', 'l1', ...
                      @(x) ismember(lower(x), {'l1', 'l2', 'tv', 'hellinger'}));
  options.addOptional('w', 1e-4, ...
                      @(x) (isscalar(x) && (x > 0)));
  options.addOptional('base_kernel', ...
                      @(counts) (counts * counts'), ...
                      @(x) (isa(x, 'function_handle')));

  options.parse(varargin{:});
  options = options.Results;

  num_graphs = max(graph_ind);

  K = zeros(num_graphs);

  iteration = 0;
  while (true)
    if verbose
        fprintf('...computing hashvalues\n')
    end
    labels = calculate_hashes(features, graph_ind, options.distance, ...
                              options.w);

                          
    if verbose
        fprintf('...computing kernel contribution\n')
    end                      
    % aggregate counts on graphs
    counts = accumarray([graph_ind, labels], 1);

    % contribution specified by base kernel on count vectors
    K = K + options.base_kernel(counts);

    % avoid unnecessary transformation on last iteration
    if (iteration == num_iterations)
      break;
    end

    if verbose
        fprintf('...label update\n')
    end
    % apply transformation to features for next step
    features = transformation(features);
    iteration = iteration + 1;
  end

end