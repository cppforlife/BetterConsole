#import <Cocoa/Cocoa.h>

@interface BCFilePathHighlighter : NSObject {
    NSTextView *_textView;
}

- (id)initWithTextView:(NSTextView *)textView;
- (void)attach;
@end
