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

using namespace hornets_nest;

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

    // Save pagerank values to file
    printf("Saving pagerank values to file %s.pr ...\n", argv[1]);
    std::ofstream ranksFile(argv[1] + std::string(".pr"));
    const pr_t *ranks = page_rank.get_page_rank_score_host();
    for (vid_t v = 0; v < graph.nV(); v++) {
        ranksFile << v << " " << ranks[v] << std::endl;
    }
    ranksFile.close();
    host::free(ranks);
    printf("Done\n");

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
