/**
 * @brief PageRank test program
 * @file
 */
#include "Static/PageRank/PageRank.cuh"
#include <StandardAPI.hpp>
#include <Graph/GraphStd.hpp>
#include <Util/CommandLineParam.hpp>
#include <iostream>
#include <fstream>
#include <string>

#include <cmath>
#include <vector>
#include <omp.h>

using namespace hornets_nest;




/**
 * Compute the L1-norm of the difference of two arrays in parallel.
 * @param x an array
 * @param y another array
 * @param N size of arrays
 * @param a initial value
 * @returns ||x-y||_1
 */
template <class TX, class TY, class TA=TX>
inline TA l1NormDeltaOmp(const TX *x, const TY *y, size_t N, TA a=TA()) {
  // ASSERT(x && y);
  #pragma omp parallel for schedule(auto) reduction(+:a)
  for (size_t i=0; i<N; ++i)
    a += TA(std::abs(x[i] - y[i]));
  return a;
}




int exec(int argc, char* argv[]) {
    using namespace timer;
    using namespace hornets_nest;
    using namespace graph::structure_prop;
    using namespace graph::parsing_prop;


    graph::GraphStd<vid_t, eoff_t> graph;
    graph.read(argv[1], PRINT_INFO | SORT);
    // CommandLineParam cmd(graph, argc, argv);

    HornetInit hornet_init(graph.nV(), graph.nE(), graph.csr_out_offsets(),
                           graph.csr_out_edges());
    HornetGraph hornet_graph(hornet_init);

    StaticPageRank page_rank(hornet_graph, 500, 1e-10, 0.85, false);

    Timer<DEVICE> TM;
    TM.start();

    page_rank.run();

    TM.stop();
    TM.print("PR---InputAsIS");

    // Retrieve pagerank values from device
    const pr_t *ranks = page_rank.get_page_rank_score_host();

    // Run reference PageRank
    StaticPageRank page_rank_ref(hornet_graph, 500, 0, 0.85, false);
    page_rank_ref.run();
    const pr_t *ranks_ref = page_rank_ref.get_page_rank_score_host();

    // Compare pagerank values with reference
    pr_t diff = l1NormDeltaOmp(ranks, ranks_ref, graph.nV());
    printf("Error: %.2e\n", diff);

	// graph::ParsingProp flag = PRINT_INFO | SORT;
	//         graph::GraphStd<vid_t, eoff_t> graphUnDir(UNDIRECTED);
  //   graphUnDir.read(argv[1],flag);

  //   HornetInit hornet_init_undir(graphUnDir.nV(), graphUnDir.nE(), graphUnDir.csr_out_offsets(),
  //                          graphUnDir.csr_out_edges());
  //   HornetGraph hornet_graph_undir(hornet_init_undir);

  //   StaticPageRank page_rank_undir(hornet_graph_undir, 500, 1e-10, 0.85, true);

  //   TM.start();

  //   page_rank_undir.run();

  //   TM.stop();
  //   TM.print("PR---Undirected---PULL");



    return 0;
}

int main(int argc, char* argv[]) {
  int ret = 0;
  {

    ret = exec(argc, argv);

  }

  return ret;
}
