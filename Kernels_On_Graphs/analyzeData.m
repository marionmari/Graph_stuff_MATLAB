

problems = {'cora'};
problems = {'citeseer', 'webkb', 'dblp', 'cora', ...
            'populated_places_1000', 'populated_places_3000', ...
            'populated_places_5000'};
        
problems = {'washington_link_graph', 'wisconsin_link_graph', 'cornell_link_graph', ...
            'texas_link_graph', ...
            'washington_cocitation', 'wisconsin_cocitation', 'cornell_cocitation', ... 
            'texas_cocitation'};   
        
problems = {'pubmed'};        
        

warning('off','all');
data_directory    = '/Users/marion/workspace/workspace_main/MarkovLogicSets/src/PropagationKernels/tmp_files/data/';  %'~/work/experiments/short_walk_kernel/datasets/';


for problem = problems
    
   
    filename = problem{:};
    load([data_directory filename])
    %     A = [0 1 0; 1 0 1; 0 1 0];
    %     labels = [1 1 2]';
    
    num_nodes = size(A,1);
    num_edges = nnz(A)/2;
    num_labels = size(unique(labels),1);
    prob_most_freq_class = max(hist(labels,num_labels))/num_nodes;
    
    fprintf('\n%s: %.0f (# edges) %.2f (most prob class)\n',problem{1},num_edges, prob_most_freq_class)
    
    
    [num_conn_comp, conn_comp_id] = graphconncomp(A);
    
    count_same_label = 0;
    count_skipped_nodes = 0;
    for c=1:num_conn_comp
        
        ids_comp = find(conn_comp_id==c);
        A_comp = A(ids_comp,ids_comp);
        labels_comp = labels(ids_comp);
        
        % diagonal degree matrix
        D = full(sum(A_comp));
        num_edges_comp = sum(D)/2;
        num_nodes_comp = size(A_comp,1);
        if num_nodes_comp <2
            continue
        end
        
%         if num_nodes_comp < 3
%             count_skipped_nodes = count_skipped_nodes + 1;
%             continue
%         end
          
        % row-normalized adjacency matrix
        W = bsxfun(@times, 1 ./ sum(A_comp, 2), A_comp);

        [Vec,Val] = eigs(W');
        Val = diag(Val);
        Val = round(Val*1000)/1000;
        id = find(Val == max(Val(:)));

        % TODO: several maxima
        prob = Vec(:,id)/sum(Vec(:,id));

        count_same_label_comp = 0;
        for i=1:size(A_comp,1)
            
            tmp = find(W(i,:));

            id_same_label = find(labels_comp(i)*ones(nnz(A_comp(i,:)),1) == labels_comp(tmp));
            if ~isempty(id_same_label)
                count_same_label_comp = count_same_label_comp + prob(i)*sum(W(i,tmp(id_same_label)));
            end

        end
        
        count_same_label = count_same_label + count_same_label_comp * num_nodes_comp;
        
    end
    count_same_label = count_same_label/(num_nodes-count_skipped_nodes);
    fprintf('%s: %f (%d connected components)\n',problem{1},1-count_same_label, num_conn_comp)
    
end



