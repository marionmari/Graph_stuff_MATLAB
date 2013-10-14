function GD_PlotFunction(handle,points,f, titlestring, rangemin, rangemax)
% Usage: GD_PlotFunction(handle,points,f,  titlestring, rangemin, rangemax)
% 
% Input: handle of the axis to plot into
%        points: matrix, size (num_points, 2)
%        f: vector, size (n,1); function values to plot
%        titlestring: the string to put in the title of the figures
%        rangemin and rangemax: min and max range to be used in the colorbar. 
%             the last two arguments are optional. can be used to let several 
%             plots have the same colorrange. 


if (nargin == 4) %no range was specified
  rangemin = min(f);
  rangemax = max(f); 
end


% rescale and shift to fit to colormap:
f = f - rangemin; % make non-neg
if(isequal(rangemin, rangemax))
  warning('plot_function: all function values are the same, reset them to 1 for plotting')
  f = ones(size(f));
else
  f = f ./ (rangemax - rangemin) * 60; % rescale
end

% plot it:
colors = colormap; 
scatter(handle,points(:,1),points(:,2),20,colors(floor(f)+1,:),'filled');
title(handle,titlestring);
axis(handle,'equal');
