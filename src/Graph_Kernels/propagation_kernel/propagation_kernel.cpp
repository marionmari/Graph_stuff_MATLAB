#include <math.h>

#include <tr1/functional>
#include <tr1/unordered_map>
using std::tr1::hash;
using std::tr1::unordered_map;

#include <boost/random.hpp>
using boost::variate_generator;
using boost::normal_distribution;
using boost::cauchy_distribution;
typedef boost::mt19937 base_generator_type;

#define INDEX(row, column, num_rows) ((int)(row) + ((int)(num_rows) * (int)(column)))

extern "C" {
#include <cblas.h>

	void calculate_propagation_kernel_contribution(double *probabilities,
																								 int *graph_ind,
																								 double w,
																								 int p,
																								 int num_nodes,
																								 int num_classes,
																								 int num_graphs,
																								 double *kernel_matrix)
	{
		int i, j, *labels;
		double *random_offsets, *signatures, *feature_vectors;
		bool use_cauchy = (p == 1);

		unordered_map<double, int, hash<double> > signature_hash;

		base_generator_type generator(0);

		normal_distribution<double> normal(0, 1);
		variate_generator<base_generator_type&, normal_distribution<double> >
			randn(generator, normal);

		cauchy_distribution<double> cauchy(0, 1);
		variate_generator<base_generator_type&, cauchy_distribution<double> >
			randc(generator, cauchy);

		labels = new int[num_nodes];
		signatures = new double[num_nodes]();

		random_offsets = new double[num_classes - 1];
		for (i = 0; i < num_classes - 1; i++)
			if (use_cauchy)
				random_offsets[i] = randc();
			else
				random_offsets[i] = randn();

		if (!use_cauchy)
			for (i = 0; i < num_nodes; i++)
				for (j = 0; j < num_classes - 1; j++)
					probabilities[INDEX(i, j, num_nodes)] = sqrt(probabilities[INDEX(i, j, num_nodes)]);

		cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, num_nodes, 1, num_classes - 1, 1,
								probabilities, num_nodes, random_offsets, num_classes - 1, 1, signatures, num_nodes);

		for (i = 0; i < num_nodes; i++)
			signatures[i] = floor(signatures[i] / w);

		num_classes = 0;
		for (i = 0; i < num_nodes; i++) {
			if (signature_hash.count(signatures[i]) == 0) {
				num_classes++;
				labels[i] = num_classes;
				signature_hash[signatures[i]] = num_classes;
			}
			else
				labels[i] = signature_hash[signatures[i]];
		}

		feature_vectors = new double[num_graphs * num_classes]();
		for (i = 0; i < num_nodes; i++)
			feature_vectors[INDEX(graph_ind[i] - 1, labels[i] - 1, num_graphs)]++;

		cblas_dsyrk(CblasColMajor, CblasUpper, CblasNoTrans, num_graphs, num_classes,
								1.0, feature_vectors, num_graphs, 0.0, kernel_matrix, num_graphs);

		delete[] labels;
		delete[] feature_vectors;
		delete[] random_offsets;
		delete[] signatures;
	}

}
