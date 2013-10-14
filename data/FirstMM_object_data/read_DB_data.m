  
%==========================================================================
% Copyright (C) 2013
% Marion Neumann [marion dot neumann at uni-bonn dot de]
% Plinio Moreno [plinio at isr dot ist dot utl dot pt]
% Laura Antanas [laura dot antanas at cs dot kuleuven dot be]
%
% This file is part of FirstMM_object_data.
%
% FirstMM_object_data by M. Neumann, P. Moreno, L. Antanas is licensed 
% under a Creative Commons Attribution-ShareAlike 3.0 Unported License 
% (http://creativecommons.org/licenses/by-sa/3.0/).
%
% FirstMM_object_data is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the Creative
% Commons Attribution-ShareAlike 3.0 Unported License for more details.
%
% You should have received a copy of the Creative Commons 
% Attribution-ShareAlike 3.0 Unported License along with this program;
% if not, see <http://creativecommons.org/licenses/by-sa/3.0/>.
%==========================================================================

    % REGION indexes (part labels):
    % 1 'bottom'
    % 2 'middle'
    % 3 'top'
    % 4 'handle'
    % 5 'usable_area'
    
    [obj_category, ~, obj_list] = tblread('objs_cats_DB.txt');
    
    % OBJECT categories
    map_cat2str = {'cup', 'glass', 'can', 'knife', 'pot', 'pan', 'bowl', 'kitchen_tool', 'screwdriver', 'hammer', 'bottle'}';
    m = containers.Map(map_cat2str, 1:numel(map_cat2str));
    
    % INITIALIZATION
    A = [];
    node_labels = [];
    graph_ind = [];
    pcs = double.empty(0,30);
    labels = [];
    counter = 0;
    for i = 3:9%size(obj_list,1)
        if i == 7
            continue
        end
        counter = counter +1;
        obj_name = char(obj_list(i,:));
        filename = strrep(obj_name, ' ', '')
        Obj = load(filename)
        
        % read data
        pointCloudObjectFrame = Obj.pointCloudObjectFrame';  % point clouds
        regionIndexes = Obj.regionIndexes';                  % part labels
        normals = Obj.normals;                              % normals
        knn_graph = Obj.knn_graph;                          % weighted kNN-graph (k=4)           
        category = Obj.category;                            % object category
        %category = map_cat2str(obj_category(i));           % another way to access object category
        
%         % plot data
%         plot_edges = false;
%         plot_object(pointCloudObjectFrame', knn_graph, regionIndexes, plot_edges);

        A = sparse(blkdiag(A,knn_graph));

        node_labels = [node_labels; regionIndexes];
        pcs = [pcs; pointCloudObjectFrame];
        graph_ind = [graph_ind; counter*ones(size(knn_graph,1),1)];
        
        labels = [labels; m(category{1})];
    
    end




