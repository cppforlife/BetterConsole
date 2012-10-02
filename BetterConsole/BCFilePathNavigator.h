#import <Cocoa/Cocoa.h>

@interface BCFilePathNavigator : NSObject
+ (void)attachToTextView:(NSTextView *)textView;
@end

@interface BCFilePathNavigator (Navigation)
+ (void)openFilePath:(NSString *)filePath
          lineNumber:(NSUInteger)lineNumber
     inEditorContext:(id)editorContext;

+ (void)withBestPossibleEditorContext:(void(^)(id))editorContextBlock;

+ (void)openAdjacentEditorContextTo:(id)editorContext
                           callback:(void(^)(id))editorContextBlock;
@end
