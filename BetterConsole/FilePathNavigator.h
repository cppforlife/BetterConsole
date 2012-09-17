#import <Cocoa/Cocoa.h>

@interface FilePathNavigator : NSObject {
    NSTextView *_textView;
}

- (id)initWithTextView:(NSTextView *)textView;
- (void)attach;
@end
