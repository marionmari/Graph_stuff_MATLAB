function Graphs = make_nino_struct(A, labels, graph_ind)
    
    Graphs = struct('am', {}, 'nl', {}, 'el', {}, 'al', {})
    
    for i=unique(graph_ind)

        
        ids = find(graph_ind==i);
        Graphs(i).am = A(ids,ids);
        
            
        node_list
        edge_list
        adj_list
        
        
    end
    
end

