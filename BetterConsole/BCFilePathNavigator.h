#import <Cocoa/Cocoa.h>

@interface BCFilePathNavigator : NSObject {
    NSTextView *_textView;
}

- (id)initWithTextView:(NSTextView *)textView;
- (void)attach;
@end
