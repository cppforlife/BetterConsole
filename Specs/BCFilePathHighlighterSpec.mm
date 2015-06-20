#import <Cedar/Cedar.h>
#import "BCFilePathHighlighter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(BCFilePathHighlighterSpec)

describe(@"BCFilePathHighlighter", ^{
    it(@"should match a simple file path", ^{
        [BCFilePathHighlighter isFilePath:@"/tmp/foo.m:88"] should be_truthy;
    });

    it(@"should not match an empty string", ^{
        [BCFilePathHighlighter isFilePath:@""] should_not be_truthy;
    });

    it(@"should not match a CoreLocation object description", ^{
        NSString *coreLocationDescription = @"/- 5.00m (speed 5.00 mps / course 5.00) @ 6/19/15, 10:23";
        [BCFilePathHighlighter isFilePath:coreLocationDescription] should_not be_truthy;
    });
});

SPEC_END
