% imagine this existed:
%
% Graphs = make_nino_struct(A, labels, graph_ind)
%
% then I could do:
%
% kernel = get_nino_handle(@WL, h, nl);
%
% and use
%
% K = kernel(A, labels, graph_ind);

function kernel = get_nino_handle(kernel, varargin)

  kernel = @(A, labels, graph_ind) ...
           kernel(make_nino_struct(A, labels, graph_ind), varargin{:});

end