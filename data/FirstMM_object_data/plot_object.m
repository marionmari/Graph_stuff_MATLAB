
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


function plot_object(points, A, labels, plot_graph)
  
  %colors = {'r', 'b', 'y', 'g', 'c', 'black'};
  colors = [1, 0, 0;
            0, 0, 1;
            1, 1, 0;
            0, 1, 0;
            0, 1, 1;
            0.5, 0.5, 0.5];

%   figure;
  hold('on');
  for i = 1:max(labels)
    ind = (labels == i);
    if (any(ind))
        scatter3(points(ind, 1), points(ind, 2), points(ind, 3), [], ...
               colors(i, :), 'x');
    end
  end
  
  % PLOT edges (edge weights are NOT considered!) THIS IS SLOW!
  if plot_graph
      [from, to] = find(A);
      for i = 1:numel(from)
        ind = [from(i), to(i)];
        try
            plot3(points(ind, 1), points(ind, 2), points(ind, 3), 'color', ...
              (colors(labels(from(i)), :) + colors(labels(to(i)), :)) / 2);
        catch
        end
      end
  end
  axis('equal');
%   axis off;
  hold('off');
end