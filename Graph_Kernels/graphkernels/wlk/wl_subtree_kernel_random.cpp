#include "mex.h"
#include "matrix.h"
#include <math.h>
#include <string.h>
#include <iostream>
using std::cout;
using std::endl;

#include <tr1/functional>
#include <tr1/unordered_map>
using std::tr1::hash;
using std::tr1::unordered_map;

#include <boost/random.hpp>
#include <boost/random/variate_generator.hpp>
using boost::uniform_real;
using boost::variate_generator;

typedef boost::mt19937 base_generator_type;

extern "C" {
#include <cblas.h>
}

/* convenience macros for input/output indices in case we want to change */
#define A_ARG               prhs[0]
#define LABELS_ARG          prhs[1]
#define GRAPH_IND_ARG       prhs[2]
#define H_ARG               prhs[3]

#define KERNEL_MATRIX_ARG   plhs[0]

#define INDEX(row, column, num_rows) ((int)(row) + ((int)(num_rows) * (int)(column)))

void mexFunction(int nlhs, mxArray *plhs[],
								 int nrhs, const mxArray *prhs[])
{
	mwIndex *A_ir, *A_jc;
	double *graph_ind, *labels_in, *h_in, *kernel_matrix;
	int h, *labels;

	int i, j, count, iteration, num_nodes, num_labels, num_new_labels, num_graphs,
		num_neighbors, *new_labels;

	double *feature_vectors, *random_offsets, signature;

	unordered_map<double, int, hash<double> > signature_hash;

	base_generator_type generator(0);

	uniform_real<double> uniform_distribution(0, 1);
	variate_generator<base_generator_type&, uniform_real<double> >
		rand(generator, uniform_distribution);

	A_ir      = mxGetIr(A_ARG);
	A_jc      = mxGetJc(A_ARG);

	labels_in = mxGetPr(LABELS_ARG);

	graph_ind = mxGetPr(GRAPH_IND_ARG);
	h_in      = mxGetPr(H_ARG);

	/* dereference to avoid annoying casting and indexing */
	h         = (int)(h_in[0] + 0.5);

	num_nodes = mxGetN(A_ARG);

	/* copy label matrix because we will overwrite it */
	labels = new int[num_nodes];
	for (i = 0; i < num_nodes; i++)
		labels[i] = (int)(labels_in[i] + 0.5);

	num_labels = 0;
	num_graphs = 0;
	for (i = 0; i < num_nodes; i++) {
		if (labels[i] > num_labels)
			num_labels = (int)(labels[i]);
		if ((int)(graph_ind[i]) > num_graphs)
			num_graphs = (int)(graph_ind[i] + 0.5);
	}

	KERNEL_MATRIX_ARG = mxCreateDoubleMatrix(num_graphs, num_graphs, mxREAL);
	kernel_matrix = mxGetPr(KERNEL_MATRIX_ARG);

	feature_vectors = NULL;
	new_labels      = new int[num_nodes];
	random_offsets  = new double[num_nodes];
	for (i = 0; i < num_nodes; i++)
		random_offsets[i] = rand();

	iteration = 0;
	while (true) {

		delete[] feature_vectors;
		feature_vectors = new double[num_graphs * num_labels]();

		for (i = 0; i < num_nodes; i++)
			feature_vectors[INDEX(graph_ind[i] - 1, labels[i] - 1, num_graphs)]++;

		cblas_dsyrk(CblasColMajor, CblasUpper, CblasNoTrans, num_graphs, num_labels,
		 						1.0, feature_vectors, num_graphs, 1.0, kernel_matrix, num_graphs);

		if (iteration == h)
			break;

		count = 0;
		num_new_labels = 0;
		signature_hash.clear();
		for (i = 0; i < num_nodes; i++) {
			signature = (double)(labels[i]);
			
			num_neighbors = A_jc[i + 1] - A_jc[i];
			for (j = 0; j < num_neighbors; j++, count++)
				signature += random_offsets[labels[A_ir[count]] - 1];

			if (signature_hash.count(signature) == 0) {
				new_labels[i] = ++num_new_labels;
				signature_hash[signature] = num_new_labels;
			}
			else
				new_labels[i] = signature_hash[signature];
		}

		num_labels = num_new_labels;
		memcpy(labels, new_labels, num_nodes * sizeof(int));
		
		iteration++;
	}

	delete[] labels;
	delete[] new_labels;
	delete[] feature_vectors;
	delete[] random_offsets;

}
