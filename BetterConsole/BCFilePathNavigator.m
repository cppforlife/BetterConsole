#import "BCFilePathNavigator.h"
#import <objc/runtime.h>

@interface BCFilePathNavigator (BCClassDump)
- (id)initWithDocumentURL:(NSURL *)url timestamp:(id)timestamp lineRange:(NSRange)lineRange;
- (id)structureEditorOpenSpecifierForDocumentLocation:(id)location inWorkspace:(id)workspace error:(id*)error;
- (void)openEditorOpenSpecifier:(id)openSpecifier;
- (void)_doOpenIn_AdjacentEditor_withWorkspaceTabController:(id)workspaceTabController editorContext:(id)editorContext documentURL:(id)url usingBlock:(id)block;

- (id)lastActiveWorkspaceWindow;
- (id)windowController;
- (id)workspace;
- (id)document;
- (id)editorArea;
- (id)lastActiveEditorContext;
@end

@implementation BCFilePathNavigator

+ (void)attachToTextView:(NSTextView *)textView {
    static char Observer;

    if (!objc_getAssociatedObject(textView, &Observer)) {
        objc_setAssociatedObject(textView, &Observer, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN);

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetLocalCenter(),
            NULL, BCFilePathNavigator_Handler,
            (CFStringRef)NSTextViewDidChangeSelectionNotification,
            textView, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}

void BCFilePathNavigator_Handler(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSTextView *textView = (NSTextView *)object;
    NSRange range = textView.selectedRange;

    if (range.length == 0 && textView.textStorage.length > range.location) {
        NSDictionary *attributes = [textView.textStorage attributesAtIndex:range.location effectiveRange:NULL];
        NSString *filePathAndLineNumber = [attributes objectForKey:@"BetterConsoleFilePath"];

        NSLog(@"Clicked on file path - %@", filePathAndLineNumber);
        if (!filePathAndLineNumber) return;

        NSArray *components = [filePathAndLineNumber componentsSeparatedByString:@":"];
        NSString *filePath = [components objectAtIndex:0];

        NSNumberFormatter* formatter = [[[NSNumberFormatter alloc] init] autorelease];
        NSUInteger lineNumber = [[formatter numberFromString:[components objectAtIndex:1]] unsignedIntegerValue];

        [BCFilePathNavigator withBestPossibleEditorContext:^(id editorContext){
            [BCFilePathNavigator openFilePath:filePath lineNumber:lineNumber inEditorContext:editorContext];
        }];
    }
}
@end

@implementation BCFilePathNavigator (Navigation)

+ (void)openFilePath:(NSString *)filePath lineNumber:(NSUInteger)lineNumber inEditorContext:(id)editorContext {
    id location =
        [[[NSClassFromString(@"DVTTextDocumentLocation") alloc]
            initWithDocumentURL:[NSURL fileURLWithPath:filePath]
            timestamp:nil
            lineRange:NSMakeRange(MAX(0, lineNumber-1), 1)] autorelease];

    [editorContext openEditorOpenSpecifier:
        [NSClassFromString(@"IDEEditorOpenSpecifier")
            structureEditorOpenSpecifierForDocumentLocation:location
            inWorkspace:[editorContext workspace]
            error:NULL]];
}

+ (void)withBestPossibleEditorContext:(void(^)(id))editorContextBlock {
    id editorArea = [self _currentEditorArea];
    id lastEditorContext = [editorArea lastActiveEditorContext];

    if ([NSEvent modifierFlags] & NSAlternateKeyMask) {
        [self openAdjacentEditorContextTo:lastEditorContext callback:editorContextBlock];
    } else {
        editorContextBlock(lastEditorContext);
    }
}

+ (void)openAdjacentEditorContextTo:(id)editorContext callback:(void(^)(id))editorContextBlock {
    [NSClassFromString(@"IDEEditorCoordinator")
        _doOpenIn_AdjacentEditor_withWorkspaceTabController:nil
        editorContext:editorContext
        documentURL:nil
        usingBlock:editorContextBlock];
}

+ (id)_currentEditorArea {
    id window = [NSClassFromString(@"IDEWorkspaceWindow") lastActiveWorkspaceWindow];
    id workspaceWindowController = [window windowController];
    return [workspaceWindowController editorArea];
}
@end
