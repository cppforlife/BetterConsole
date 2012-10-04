#import <Cocoa/Cocoa.h>

@interface BCFilePathNavigator : NSObject
+ (void)attachToTextView:(NSTextView *)textView;
@end

@interface BCFilePathNavigator (Editors)
+ (id)editorContextShowingFilePath:(NSString *)filePath;
+ (void)bestEditorContext:(void(^)(id))editorContextBlock forFilePath:(NSString *)filePath;
@end

@interface BCFilePathNavigator (Navigation)
+ (void)openFilePath:(NSString *)filePath
          lineNumber:(NSUInteger)lineNumber
     inEditorContext:(id)editorContext;

+ (void)openAdjacentEditorContextTo:(id)editorContext callback:(void(^)(id))editorContextBlock;
+ (void)openEditorContextSelectionFrom:(id)editorContext callback:(void(^)(id))editorContextBlock;
@end
