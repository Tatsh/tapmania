#include "ObjCPtr.h"

namespace AtomicCounters
{
    counter interlocked_increment(counter *c)
    {
#if defined(__MACH__) || defined(__linux__)
        return __sync_add_and_fetch(c, 1);
#else
        return ++c;
#endif
    }

    counter interlocked_decrement(counter *c)
    {
#if defined(__MACH__) || defined(__linux__)
        return __sync_sub_and_fetch(c, 1);
#else
        return --c;
#endif
    }
}
