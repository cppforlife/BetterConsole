#import "BCUtils.h"
#include <sys/time.h>
#include <sys/resource.h>

double BCTime() {
    struct timeval t;
    struct timezone tzp;
    gettimeofday(&t, &tzp);
    return t.tv_sec + t.tv_usec*1e-6;
}
