function K = propagation_kernel(features, graph_ind, transformation, ...
                                num_iterations, varargin)

  verbose = false;
                            
  options = inputParser;

  options.addOptional('distance', 'l1', ...
                      @(x) ismember(lower(x), {'l1', 'l2', 'tv', 'hellinger'}));
  options.addOptional('w', 1e-4, ...
                      @(x) (isscalar(x) && (x > 0)));
  options.addOptional('base_kernel', ...
                      @(counts) (counts * counts'), ...
                      @(x) (isa(x, 'function_handle')));

  options.addOptional('attr', [], ...
                      @(x) (ismatrix(x)));
  options.addOptional('w_attr', 1, ...
                      @(x) (isscalar(x) && (x > 0)));            
  options.addOptional('trans_attr', @(x) (x), ...
                      @(x) (isa(x, 'function_handle'))); 
  options.addOptional('dist_attr', 'l1', ...
                      @(x) ismember(lower(x), {'l1', 'l2', 'tv', 'hellinger'}));                
                       
  
  options.parse(varargin{:});
  options = options.Results;
  
  if ~isempty(options.attr)
      attributes = options.attr;    % attributes or attribute distributions
  end

  num_graphs = max(graph_ind);

  K = zeros(num_graphs);
  K_all = zeros(num_graphs,num_graphs,num_iterations+1);  
  
  iteration = 0;
  while (true)
      
    if (verbose); fprintf('...computing hashvalues\n');  end
    labels = calculate_hashes(features, options.distance, options.w);                
    
    if verbose
        if (iteration == 0); fprintf('num hashlabels = ');  end
        num_labels = size(unique(labels),1); 
        fprintf('%d...', num_labels);  
    end
    
    if ~isempty(options.attr)    
       
         
        % hash each attribute seperately (MLJ experiemnts) DOES THIS MAKE
        % SENSE FOR GMMs??????
        for dim = 1:size(attributes,2)
            tmp = calculate_hashes(attributes(:,dim), options.dist_attr, 1);
            [~,~,labels_new] =  unique(labels+(tmp*max(labels)));
            if verbose && dim==1
                num_labels = size(unique(labels_new),1);
                fprintf('[%d]...', num_labels);  
            end
            counts = accumarray([graph_ind, labels_new], 1);    % aggregate counts on graphs
            K = K + options.base_kernel(counts);    % contribution specified by base kernel on count vectors
        end
        
%         % hash attributes jointly 
%         tmp = calculate_hashes(attributes, options.dist_attr, options.w_attr);
%         if verbose
%             num_labels = size(unique(tmp),1);
%         	fprintf('(%d)...', num_labels);  
%         end         
%         [~,~,labels] =  unique(labels+(tmp*max(labels)));
%         if verbose
%             num_labels = size(unique(labels),1);
%             fprintf('[%d]...', num_labels);
%         end
%         counts = accumarray([graph_ind, labels], 1);    % aggregate counts on graphs
%         K = K + options.base_kernel(counts);    % contribution specified by base kernel on count vectors
    else
        counts = accumarray([graph_ind, labels], 1);    % aggregate counts on graphs
        K = K + options.base_kernel(counts);    % contribution specified by base kernel on count vectors
    end
  

    
    K_all(:,:,iteration+1) = K;
    % avoid unnecessary transformation on last iteration
    if (iteration == num_iterations)
        if verbose
            fprintf('\n')  
        end
        break;
    end

    if verbose
        fprintf('...label update\n')
    end
    % apply transformation to label distribution features for next step
    features = transformation(features);
    
    % apply transformation to attribute distributions for next step
    attributes = options.trans_attr(attributes);
    

    iteration = iteration + 1;
  end
  % RETURN K_all
  K = K_all;
end
