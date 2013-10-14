#include "mex.h"
#include "matrix.h"

/* convenience macros for input/output indices in case we want to change */
#define PROBABILITIES_ARG prhs[0]
#define GRAPH_IND_ARG     prhs[1]
#define W_ARG             prhs[2]
#define USE_CAUCHY_ARG    prhs[3]

#define KERNEL_MATRIX_ARG plhs[0]

#define MAX(x, y) (((x) > (y)) ? (x) : (y));
#define ROUND_TO_INT(x) ((int)((x) + 0.5))

extern "C" {
	void calculate_propagation_kernel_contribution(double *,
																								 int *,
																								 double,
																								 int,
																								 int,
																								 int,
																								 int,
																								 double *);
}

void mexFunction(int nlhs, mxArray *plhs[],
								 int nrhs, const mxArray *prhs[])
{
	double *graph_ind_in, *probabilities, w, *kernel_matrix;
	int *graph_ind, p, num_nodes, num_classes, num_graphs, i;
	mxLogical *use_cauchy;

	probabilities = mxGetPr(PROBABILITIES_ARG);
	graph_ind_in  = mxGetPr(GRAPH_IND_ARG);
	w             = mxGetScalar(W_ARG);
	use_cauchy    = mxGetLogicals(USE_CAUCHY_ARG);

	num_nodes   = mxGetM(PROBABILITIES_ARG);
	num_classes = mxGetN(PROBABILITIES_ARG);

	graph_ind = new int[num_nodes];
	num_graphs  = 0;
	for (i = 0; i < num_nodes; i++) {
		graph_ind[i] = ROUND_TO_INT(graph_ind_in[i]);
		num_graphs = MAX(num_graphs, graph_ind[i]);
	}

	p = (use_cauchy[0] ? 1 : 2);

  KERNEL_MATRIX_ARG = mxCreateDoubleMatrix(num_graphs, num_graphs, mxREAL);
	kernel_matrix = mxGetPr(KERNEL_MATRIX_ARG);

	calculate_propagation_kernel_contribution(probabilities, graph_ind,
																						w, p, num_nodes, num_classes,
																						num_graphs, kernel_matrix);

	delete[] graph_ind;
}
