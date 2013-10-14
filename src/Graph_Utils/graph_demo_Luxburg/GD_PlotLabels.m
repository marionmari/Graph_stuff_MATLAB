function [handle_figure,handle_axes] = GD_PlotLabels(points,labels,titlestring)
% Usage: [handle_figure,handle_axes] = GD_PlotLabels(points,labels,titlestring)
% 
% Input: 
% points: size(num_points,2)
% labels: vector, size(num_points,1); integer values indicating the classes
% titlestring: the string for the title of the plot
% 
% plots the points and the correpsonding labels in color
% 

% this is a hack, wrote this ages ago, would need rewriting ... 

% check input: 
if (length(find(isnan(labels))) > 0)
  warning('Labels contains NaN values, stop plotting')
end

dim = size(points,2); 
if (dim > 2), warning(['plot_labels: only plotting the first two dimensions']), end 
if (size(labels,2) >= 2), error(['plot labels: label vector has wrong dimension']), end

hold all %otherwise only last class will be visible
title(titlestring)

% if we only have a few labels, always use the same colors: 
if (0) %if (max(labels) < 3) 
  plot(points(find(labels==0),1), points(find(labels==0),2), 'y*'); 
  plot(points(find(labels==1),1), points(find(labels==1),2), 'r*'); 
  plot(points(find(labels==-1),1), points(find(labels==-1),2), 'b*'); 
  plot(points(find(labels==2),1), points(find(labels==2),2), 'g*'); 
  plot(points(find(labels==3),1), points(find(labels==3),2), 'k*'); 


else   
  % otherwise, plot clusters by cycling through colors:   
  colormap(jet)
  tmp = colormap; 
  
  % random colors (but always the sames): 
  colors = colorvector(); %(rand(1000,3));
  
  colors(1,:) = [ 0 0 0];
  colors(2,:) = [ 1 1 0];
  colors(3,:) = [ 1 0 1];
  colors(4,:) = [ 0 0 1];
  colors(5,:) = [ 1 0 0];
  colors(6,:) = [ 0 1 0];
  colors(7,:) = [ 0 1 1];
  
  for it=-1:1:max(labels)
    current_color = colors(it+3,:);
    %  current_color = tmp( floor(64/max(labels + 4))* (it + 3), :);
    if (dim == 1)
      plot(points(find(labels==it),1), zeros(size(points(find(labels==it),1))),  ...
           'Color', current_color , 'MarkerSize',8, 'Marker','.','LineStyle','none')
      
    else
      plot(points(find(labels==it),1), points(find(labels==it),2), ...
           'Color',current_color, 'MarkerSize',8,  'Marker','.','LineStyle','none');
    end
  end

end

% plot NaN values: 
%plot(points(find(isnan(labels)),1), points(find(isnan(labels)),2), 'k*'); 

handle_figure = gcf; %at the end of function!!!
handle_axes = gca; 

%drawnow


function ret = colorvector()
% just want one random vector which is always the same... 
ret = [0.5019, 0.5025, 0.2169, 0.0994, 0.2977, 0.5103, 0.5457, 0.6363, 0.6239, 0.0812, 0.4533, 0.3562, 0.8261, 0.6302, 0.8031, 0.2764, 0.1589, 0.2640, 0.0255, 0.3217, 0.3369, 0.7040, 0.9193, 0.4501, 0.1509, 0.5009, 0.8675, 0.5165, 0.1409, 0.3796, 0.9142, 0.8830, 0.2679, 0.1749, 0.0447, 0.5762, 0.1228, 0.1654, 0.5973, 0.8707, 0.8210, 0.3544, 0.8263, 0.9614, 0.6624, 0.1818, 0.7313, 0.2739, 0.0821, 0.2357, 0.4798, 0.8316, 0.0393, 0.3344, 0.0285, 0.8145, 0.7304, 0.3045, 0.7458, 0.0346, 0.8839, 0.2189, 0.7826, 0.5160, 0.5854, 0.8258, 0.1989, 0.6846, 0.3148, 0.8104, 0.5008, 0.1170, 0.7660, 0.7032, 0.0907, 0.5266, 0.5500, 0.3793, 0.4021, 0.7224, 0.6654, 0.8547, 0.4670, 0.3760, 0.4226, 0.5437, 0.0490, 0.6153, 0.4627, 0.7466, 0.5542, 0.1106, 0.1530, 0.3877, 0.4427, 0.1521, 0.8454, 0.5961, 0.8286]; 

ret = reshape(ret,33,3);
