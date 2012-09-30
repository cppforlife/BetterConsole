#import <Foundation/Foundation.h>

double BCTime();

#define BCTimeLog(marker) \
    for (double t1 = BCTime(); t1 != 0; NSLog(@"%@ took %f sec.", marker, BCTime() - t1), t1 = 0)
