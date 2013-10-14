function GD_PlotGraph(points,A,titlestring)
% Usage: GD_PlotGraph(points,A,titlestring)
% Input: points = matrix of size (num_points,dim_points) 
%        A =  adjacency matrix of the graph, size (num_points, num_points)
%             Has to be non-negative, symmetric. 
%        titlestring = title for the plot
% 
% Plots the unweighted graph in 2dim plane. If dim_points > 2, only the first 2 coordinates are plotted. 

% check input: 
num_points = size(A,1); 

if (size(A,1) ~= size(A, 2)), 
  error('Adjacency matrix is not square. ')
end

if (sum(sum(A - A') > 0.0001)), 
  warning('Adjacency matrix is not symmetric. I only plot edges in one direction.')
end

if (size(points,1) ~= num_points)
  error('Number of points does not match size of adjacency matrix.' )
end


%%%%%%%%%%%%%%%%%
% decide whether plots should have color or not (color makes it slower):
color = 0; 
%%%%%%%%%%%%%%%%



if (color) % need to do some scaling
  
  % choose colormap: want light colors for small values, hence choose "autumn" but invert it:
  %  colormap 'autumn' 
  colors = colormap; 
  %  colors = colors(end:-1:1,:);
  colormap(colors)


  %find smallest *non-zero* value in A: 
  amin = min(min(  A(find(A >0)) )); 

  % find largest value in A:
  amax = max(max(A));


  % transform A to strech to full colormap: 
  % want to shift and scale A such that the edges I want to plot
  % have weights in the range [0,60]
  % all other edges have weight -Inf

  % first of all, get 0 values out of the way
  % (don't wnat to plot an edge for 0 values anyway): 
  A(find(A<=0)) = -Inf; 

  % now scaling depends on relationship between amin and amax: 
  if (amax==0) 
    % in this case there are no edges to plot anyway
    % by the last operation the matrix is now constantly -Inf
    % don't need to do anything any more
    
  elseif (amax == amin) 
    % for example in an unweighted graph
    % by last operation matrix A has either entry -Inf or amax
    % set the value of amax to 60, then will be plotted with 
    % largest color of colormap: 
    
    A = A / amin * 60; 
    
  else
    % standard case in a weighted graph, where amin < amax
    
    % shift such that amin values are now 0: 
    A = A - amin; 
    
    % scale such that values span range [0,60]: 
    A = A / (amax - amin) * 60; 
    
  end

  % add a little bit to make sure appropriate values are strictly > 0:
  % works as I set the rest to -Inf
  % does not change a lot of the color map (as it ranges up to 60):
  A = A + 0.01; 


end %if color


% plot the vertices: 
hold all
plot(points(:,1), points(:,2), 'bx');


% plot the edges, color according to weight: 
xx = zeros(2*num_points,1);
yy = zeros(2*num_points,1);
DiffVal=0; NumDiffVal=0;
%tic
for it= 1: num_points
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % changed, to improve speed
  
  if (color)
    DiffVal = unique(ceil(A(it,:)+1));
    NumDiffVal = length(DiffVal);
    for ct = 1:NumDiffVal
      indices = find(ceil(A(it,:)+1)==DiffVal(ct) & A(it,:)>0);
      %indices = find(A(it,:)>0);
      NumIndices=length(indices);
      if(NumIndices>0)
        xx(1:2:2*NumIndices)=points(it,1);
        xx(2:2:2*NumIndices)=points(indices,1);
        yy(1:2:2*NumIndices)=points(it,2);
        yy(2:2:2*NumIndices)=points(indices,2);
        plot(xx(1:2*NumIndices),yy(1:2*NumIndices),'-','color',colors(DiffVal(ct),:));
      end
    end
    
  else
    indices = find(A(it,:)>0);
    NumIndices=length(indices);
    if(NumIndices>0)
      xx(1:2:2*NumIndices)=points(it,1);
      xx(2:2:2*NumIndices)=points(indices,1);
      yy(1:2:2*NumIndices)=points(it,2);
      yy(2:2:2*NumIndices)=points(indices,2);
      plot(xx(1:2*NumIndices),yy(1:2*NumIndices),'-r');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   for jt = it + 1 : num_points
    %     if (A(it,jt) > 0 ) 
    %       plot([points(it,1), points(jt,1)], [points(it,2),points(jt,2)], 'Color', colors(ceil(A(it,jt))+1, : ) );
    %     end
    %   end
  end

end

%t=toc

title(titlestring)
axis tight

if (color)
  colormap(colors) %need to state it here again, otherwise get wrong colorbar???
  colorbar('YTick',[1,60],'YTickLabel',...
           {num2str(amin,'%2.2f'), num2str(amax,'%2.2f')})
end


