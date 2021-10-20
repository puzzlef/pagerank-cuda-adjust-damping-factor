#include <vector>
#include <string>
#include <cstdio>
#include <iostream>
#include "src/main.hxx"

using namespace std;




#define TYPE float


template <class G, class H>
void runPagerank(const G& x, const H& xt, int repeat) {
  vector<TYPE> *init = nullptr;

  // Find pagerank using default damping factor 0.85.
  auto a1 = pagerankNvgraph(xt, init, {repeat});
  auto e1 = l1Norm(a1.ranks, a1.ranks);
  printf("[%09.3f ms; %03d iters.] [%.4e err.] pagerankNvgraph\n", a1.time, a1.iterations, e1);

  // Find pagerank using custom damping factors.
  for (float damping=1.0f; damping>0.45f; damping-=0.05f) {
    auto a2 = pagerankNvgraph(xt, init, {repeat, damping});
    auto e2 = l1Norm(a2.ranks, a1.ranks);
    printf("[%09.3f ms; %03d iters.] [%.4e err.] pagerankNvgraph [damping=%.2f]\n", a2.time, a2.iterations, e2, damping);

    auto a3 = pagerankCuda(xt, init, {repeat, damping});
    auto e3 = l1Norm(a3.ranks, a1.ranks);
    printf("[%09.3f ms; %03d iters.] [%.4e err.] pagerankCuda [damping=%.2f]\n", a3.time, a3.iterations, e3, damping);

    auto a4 = pagerankSeq(xt, init, {repeat, damping});
    auto e4 = l1Norm(a4.ranks, a1.ranks);
    printf("[%09.3f ms; %03d iters.] [%.4e err.] pagerankSeq [damping=%.2f]\n", a4.time, a4.iterations, e4, damping);
  }
}


int main(int argc, char **argv) {
  char *file = argv[1];
  int repeat = argc>2? stoi(argv[2]) : 5;
  printf("Loading graph %s ...\n", file);
  auto x  = readMtx(file); println(x);
  auto xt = transposeWithDegree(x); print(xt); printf(" (transposeWithDegree)\n");
  runPagerank(x, xt, repeat);
  printf("\n");
  return 0;
}