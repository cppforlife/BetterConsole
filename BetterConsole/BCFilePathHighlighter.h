#import <Cocoa/Cocoa.h>

@interface BCFilePathHighlighter : NSObject
+ (void)attachToTextView:(NSTextView *)textView;
+ (BOOL)isFilePath:(NSString *)string;
@end
