#import "FilePathHighlighter.h"
#import <objc/runtime.h>
#import <regex.h>

@interface FilePathHighlighter ()
@property (strong, nonatomic) NSTextView *textView;
@end

@implementation FilePathHighlighter
@synthesize textView = _textView;

- (id)initWithTextView:(NSTextView *)textView {
    if (self = [super init]) {
        self.textView = textView;
    }
    return self;
}

- (void)dealloc {
    [_textView release];
    [super dealloc];
}

+ (regex_t)_filePathRegex {
    regex_t rx;
    regcomp(&rx, "(/[^:]+:[[:digit:]]+)", REG_EXTENDED);
    return rx; // leaks - regfree(&rx);
}

NSArray *FilePathHighlighter_findFilePathRanges(NSTextStorage *textStorage) {
    NSMutableArray *filePathRanges = [NSMutableArray array];
    const char *text = textStorage.string.UTF8String;

    regex_t rx = [FilePathHighlighter _filePathRegex];
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

void FilePathHighlighter_highlightFilePathRanges(NSArray *filePathRanges, NSTextStorage *textStorage) {
    for (NSValue *rangeValue in filePathRanges) {
        NSString *filePath = [textStorage.string substringWithRange:rangeValue.rangeValue];

        [textStorage addAttributes:
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSCursor pointingHandCursor], NSCursorAttributeName,
                [NSColor darkGrayColor], NSForegroundColorAttributeName,
                [NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,
                filePath, @"BetterConsoleFilePath", nil]
        range:rangeValue.rangeValue];
    }
}

void FilePathHighlighter_Handler(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSTextStorage *textStorage = (NSTextStorage *)object;
    NSArray *filePaths = FilePathHighlighter_findFilePathRanges(textStorage);
    FilePathHighlighter_highlightFilePathRanges(filePaths, textStorage);
}

- (void)attach {
    static char Observer;

    if (!objc_getAssociatedObject(self.textView, &Observer)) {
        objc_setAssociatedObject(self.textView, &Observer, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN);

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetLocalCenter(),
            NULL, FilePathHighlighter_Handler,
            (CFStringRef)NSTextStorageDidProcessEditingNotification,
            self.textView.textStorage, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}
@end
