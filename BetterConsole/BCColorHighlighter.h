#import <Cocoa/Cocoa.h>

@interface BCColorHighlighter : NSObject {
    NSTextView *_textView;
}

- (id)initWithTextView:(NSTextView *)textView;
- (void)attach;
@end