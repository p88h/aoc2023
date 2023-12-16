#define ANKERL_NANOBENCH_IMPLEMENT
#include "nanobench.h"
#include <bits/stdc++.h>
using namespace std;

typedef struct pt {
  int x, y, dx, dy;
} pt;

int bfs(pt start, const vector<string> &tiles) {
  pt current[1000], next[1000];
  pt *currptr = &current[0], *nextptr = &next[0];
  char visited[110 * 110];
  memset(visited, 0, 110 * 110);
  int curs = 1, dimx = tiles[0].size(), dimy = tiles.size(), warm = 0;
  current[0] = start;
  while (curs > 0) {
    int nexs = 0;
    for (int i = 0; i < curs; i++) {
      pt t = currptr[i];
      t.x += t.dx;
      t.y += t.dy;
      if (t.x < 0 || t.y < 0 || t.x >= dimx || t.y >= dimy)
        continue;
      int op = t.y * dimx + t.x;
      int bp = 1 << ((t.dy + 1) * 3 + (t.dx + 1));
      // cout << t.dy << " " << t.dx << " " << bp << endl;
      if ((visited[op] & bp) != 0)
        continue;
      if (!visited[op])
        warm++;
      visited[op] |= bp;
      char c = tiles[t.y][t.x];
      if (c == '.' || (c == '|' && t.dx == 0) || (c == '-' && t.dy == 0)) {
        nextptr[nexs++] = t;
      } else if (c == '|') {
        nextptr[nexs++] = pt{t.x, t.y, 0, 1};
        nextptr[nexs++] = pt{t.x, t.y, 0, -1};
      } else if (c == '-') {
        nextptr[nexs++] = pt{t.x, t.y, 1, 0};
        nextptr[nexs++] = pt{t.x, t.y, -1, 0};
      } else if (c == '/') {
        nextptr[nexs++] = pt{t.x, t.y, -t.dy, -t.dx};
      } else if (c == '\\') {
        nextptr[nexs++] = pt{t.x, t.y, t.dy, t.dx};
      }
    }
    pt *tmp = currptr;
    currptr = nextptr;
    nextptr = tmp;
    curs = nexs;
  }
  return warm;
}

pt start(int i, int dimx, int dimy) {
  if (i < dimx)
    return pt{i, -1, 0, 1};
  if (i < 2 * dimx)
    return pt{i - dimx, dimy, 0, -1};
  if (i < 2 * dimx + dimy)
    return pt{-1, i - 2 * dimx, 1, 0};
  return pt{dimy, i - 2 * dimx - dimy, -1, 0};
}

int part2(const vector<string> &lines) {
  int mm = 0;
  int dimx = lines.size();
  int dimy = lines[0].size();
  for (int i = 0; i < 2 * dimx + 2 * dimy; i++) {
    int t = bfs(start(i, dimx, dimy), lines);
    if (t > mm)
      mm = t;
  }
  return mm;
}

int part2_parallel(const vector<string> &lines) {
  int dimx = lines.size();
  int dimy = lines[0].size();
  std::vector<std::thread> workers;
  std::vector<int> results(24, 0);
  for (int n = 0; n < 24; n++)
    workers.push_back(std::thread([&] {
      int mm = 0;
      for (int i = n; i < 2 * dimx + 2 * dimy; i += 24) {
        int t = bfs(start(i, dimx, dimy), lines);
        if (t > mm)
          mm = t;
      }
      results[n] = mm;
    }));
  for (auto &worker: workers) worker.join();
  auto it = max_element(begin(results), end(results));
  return *it;
}

int main() {
  ios_base::sync_with_stdio(false);
  cin.tie(0);
  ifstream file("day16.txt");
  string s;
  vector<string> lines;
  while (getline(file, s))
    lines.push_back(s);
  cout << bfs(pt{-1, 0, 1, 0}, lines) << endl;
  cout << part2(lines) << endl;
  cout << part2_parallel(lines) << endl;
  long tot = 0;
  ankerl::nanobench::Bench()
  .minEpochIterations(100)
  .run("part2", [&] {
    tot += part2(lines);
    ankerl::nanobench::doNotOptimizeAway(tot);
  });
  ankerl::nanobench::Bench()
  .minEpochIterations(100)
  .run("part2_parallel", [&] {
    tot += part2_parallel(lines);
    ankerl::nanobench::doNotOptimizeAway(tot);
  });
}
