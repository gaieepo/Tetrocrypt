#ifndef PCFINDER_H
#define PCFINDER_H

#include <sstream>
#include <vector>
#include <string>
#include "core/field.hpp"
#include "finder/thread_pool.hpp"
#include "finder/concurrent_perfect_clear.hpp"

auto factory = core::Factory::create();
auto threadPool = finder::ThreadPool(1);
auto pcfinder = finder::ConcurrentPerfectClearFinder<core::srs::MoveGenerator>(factory, threadPool);

static const unsigned char BitsSetTable256[256] =
{
#define B2(n) n,     n+1,     n+1,     n+2
#define B4(n) B2(n), B2(n+1), B2(n+1), B2(n+2)
#define B6(n) B4(n), B4(n+1), B4(n+1), B4(n+2)
  B6(0), B6(1), B6(1), B6(2)
};

#endif
