#import "BCFilePathHighlighter.h"
#import "BCUtils.h"
#import <objc/runtime.h>
#import <regex.h>

@implementation BCFilePathHighlighter

+ (void)attachToTextView:(NSTextView *)textView {
    static char Observer;

    if (!objc_getAssociatedObject(textView, &Observer)) {
        objc_setAssociatedObject(textView, &Observer, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN);

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetLocalCenter(),
            NULL, BCFilePathHighlighter_Handler,
            (CFStringRef)NSTextStorageDidProcessEditingNotification,
            textView.textStorage, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}

+ (regex_t)_filePathRegex {
    static regex_t *rx = NULL;
    if (!rx) {
        rx = malloc(sizeof(regex_t));
        regcomp(rx, "([\\*]?/[^:\n\r]+.[a-zA-Z]:[[:digit:]]+)", REG_EXTENDED);
    }
    return *rx;
}

NSArray *BCFilePathHighlighter_findFilePathRanges(NSTextStorage *textStorage) {
    NSMutableArray *filePathRanges = [NSMutableArray array];

    // forcefully ascii-ize string to obtain ranges that could be used on NSString
    NSString *nilTerminated = [textStorage.string stringByAppendingString:@"\0"];
    const char *text = [nilTerminated dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES].bytes;

    regex_t rx = [BCFilePathHighlighter _filePathRegex];
    regmatch_t *matches = malloc((rx.re_nsub+1) * sizeof(regmatch_t));
    NSUInteger matchStartIndex = 0;

    while (regexec(&rx, text + matchStartIndex, rx.re_nsub+1, matches, 0) == 0) {
        NSRange range = NSMakeRange(
            (NSUInteger)(matches[1].rm_so + matchStartIndex),
            (NSUInteger)(matches[1].rm_eo - matches[1].rm_so));
        [filePathRanges addObject:[NSValue valueWithRange:range]];
        matchStartIndex += matches[1].rm_eo;
    }

    free(matches);
    return filePathRanges;
}

void BCFilePathHighlighter_highlightFilePathRanges(NSTextStorage *textStorage, NSArray *filePathRanges) {
    for (NSValue *rangeValue in filePathRanges) {
        NSRange range = rangeValue.rangeValue;
        NSString *filePath = [textStorage.string substringWithRange:range];

        [textStorage addAttributes:
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSCursor pointingHandCursor], NSCursorAttributeName,
                [NSColor darkGrayColor], NSForegroundColorAttributeName,
                [NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,
                filePath, @"BetterConsoleFilePath", nil]
        range:range];
    }
}

void BCFilePathHighlighter_Handler(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    BCTimeLog(@"BetterConsole - FilePathHightlighter") {
        NSTextStorage *textStorage = (NSTextStorage *)object;
        NSArray *filePathRanges = BCFilePathHighlighter_findFilePathRanges(textStorage);
        BCFilePathHighlighter_highlightFilePathRanges(textStorage, filePathRanges);
    }
}
@end
