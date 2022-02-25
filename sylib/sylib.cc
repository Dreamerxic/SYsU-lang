#include "sylib.h"
#include <chrono>
#include <cstdio>
#include <tuple>
#include <vector>

/* Timing function implementation */
static struct WuK_Timer {
  using Clock = std::chrono::high_resolution_clock;
  std::vector<std::tuple<int, Clock::time_point>> t1, t2;
  ~WuK_Timer() {
    long long sum_us = 0;
    for (int i = 0; i < t2.size(); ++i) {
      auto us = std::chrono::duration_cast<std::chrono::microseconds>(
                    std::get<1>(t2[i]) - std::get<1>(t1[i]))
                    .count();
      sum_us += us;
      auto s = us / 1000000;
      us %= 1000000;
      auto m = s / 60;
      s %= 60;
      auto h = m / 60;
      m %= 60;
      std::fprintf(stderr, "Timer@%04d-%04d: ", std::get<0>(t1[i]),
                   std::get<0>(t2[i]));
      std::fprintf(stderr, "%dH-%dM-%dS-%dus\n", (int)h, (int)m, (int)s,
                   (int)us);
    }
    auto us = sum_us;
    auto s = us / 1000000;
    us %= 1000000;
    auto m = s / 60;
    s %= 60;
    auto h = m / 60;
    m %= 60;
    std::fprintf(stderr, "TOTAL: ");
    std::fprintf(stderr, "%dH-%dM-%dS-%dus\n", (int)h, (int)m, (int)s, (int)us);
  }
  void start(int lineno) {
    if (t1.size() == t1.capacity()) {
      t1.reserve(t1.size() + (t1.size() >> 1 | 1));
    }
    if (t2.size() == t2.capacity()) {
      t2.reserve(t2.size() + (t2.size() >> 1 | 1));
    }
    t1.emplace_back(lineno, Clock::now());
  }
  void stop(int lineno) { t2.emplace_back(lineno, Clock::now()); }
} wuk_timer;

#ifdef __cplusplus
extern "C" {
#endif
void _sysy_starttime(int lineno) { wuk_timer.start(lineno); }
void _sysy_stoptime(int lineno) { wuk_timer.stop(lineno); }

/* Input & output functions */
int getch() {
  char c;
  std::scanf("%c", &c);
  return (int)c;
}
void putch(int a) { std::printf("%c", a); }

int getint() {
  int t;
  std::scanf("%d", &t);
  return t;
}
void putint(int a) { std::printf("%d", a); }

int getarray(int a[]) {
  int n = getint();
  int i = 0;
  while (i < n) {
    a[i] = getint();
    i = i + 1;
  }
  return n;
}
void putarray(int n, int a[]) {
  putint(n);
  putch(":"[0]);
  int i = 0;
  while (i < n) {
    putch(" "[0]);
    putint(a[i]);
    i = i + 1;
  }
  putch("\n"[0]);
}
#ifdef __cplusplus
}
#endif