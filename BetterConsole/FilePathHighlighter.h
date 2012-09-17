#import <Cocoa/Cocoa.h>

@interface FilePathHighlighter : NSObject {
    NSTextView *_textView;
}

- (id)initWithTextView:(NSTextView *)textView;
- (void)attach;
@end
