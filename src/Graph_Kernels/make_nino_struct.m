function Graphs = make_nino_struct(A, labels, graph_ind)
    
    Graphs = struct('am', {}, 'nl', {}, 'el', {}, 'al', {})
    
    for i=unique(graph_ind)
        
        ids = find(graph_ind==i);
        num_nodes =  size(ids,1);
        
        % am
        curr_A = A(ids,ids);
        Graphs(i).am = curr_A;
        
        % nl
        node_list = struct(values, labels(ids,1));
        Graphs(i).nl = node_list;
            
        % el
        [row, col] = find(curr_A);
        val = ones(num_nodes,1);
        edge_array =  [col, row, val];
        edge_list = struct(values, edge_array);
        Graphs(i).el = node_list;
        
        % al
        adj_list = cell(num_nodes,1);
        for j=1:num_nodes
            adj_list{j} = find(curr_A(j, : ));
        end
        Graphs(i).al = adj_list;
        
    end
    
end

