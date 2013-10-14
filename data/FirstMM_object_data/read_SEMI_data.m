
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

    [obj_category, ~, obj_list] = tblread('objs_cats_SEMI.txt');
    
    % OBJECT categories
    map_cat2str = {'cup', 'glass', 'can', 'knife', 'pot', 'pan', 'bowl', 'kitchen_tool', 'screwdriver', 'hammer', 'bottle'}';
   
    max_num_views = 8;
    for i = 20:size(obj_list,1)
        for j = 1:1%max_num_views

            try
                obj_name = char(obj_list(i,:));
                obj_name = strrep(obj_name, ' ', '');
                obj_name = strcat(obj_name,'_view_',int2str(j));
                filename = strcat('./SEMI/',obj_name, '.mat')
                Obj = load(filename)
            catch
                % no data for this view
                continue
            end

            % read data
            pointCloudObjectFrame = Obj.pointCloudObjectFrame;  % point clouds
            regionIndexes = Obj.regionIndexes;                  % part labels
            normals = Obj.normals;                              % normals
            knn_graph = Obj.knn_graph;                          % weighted kNN-graph (k=4)           
            category = Obj.category;                            % object category
            %category = map_cat2str(obj_category(i));           % another way to access object category
            
            % plot data
            plot_edges = false;
            plot_object(pointCloudObjectFrame', knn_graph, regionIndexes', plot_edges);
            
        end
    end




