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

NSArray *FilePathHighlighter_findFilePaths(NSTextStorage *textStorage) {
    regex_t rx = [FilePathHighlighter _filePathRegex];
    regmatch_t *matches;
    matches = (regmatch_t *)malloc((rx.re_nsub+1) * sizeof(regmatch_t));

    NSMutableArray *filePaths = [NSMutableArray array];
    const char *buf = [textStorage.string UTF8String];

    while(regexec(&rx, buf, rx.re_nsub+1, matches, 0) == 0) {
        const void *bytes = (buf + matches[1].rm_so);
        NSUInteger length = (NSInteger)(matches[1].rm_eo - matches[1].rm_so);

        NSString *filePath = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
        [filePaths addObject:filePath];
        [filePath release];

        buf = bytes + length;
    }

    free(matches);
    return filePaths;
}

void FilePathHighlighter_highlightFilePaths(NSArray *filePaths, NSTextStorage *textStorage) {
    for (NSString *filePath in filePaths) {
        NSRange range = [textStorage.string rangeOfString:filePath];
        if (range.location != NSNotFound) {
            [textStorage addAttributes:@{
                NSCursorAttributeName : [NSCursor pointingHandCursor],
                NSForegroundColorAttributeName : [NSColor darkGrayColor],
                NSUnderlineStyleAttributeName : @1,
                @"BetterConsoleFilePath" : filePath
            } range:range];
        }
    }
}

void FilePathHighlighter_Handler(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSTextStorage *textStorage = (NSTextStorage *)object;
    NSArray *filePaths = FilePathHighlighter_findFilePaths(textStorage);
    FilePathHighlighter_highlightFilePaths(filePaths, textStorage);
}

- (void)attach {
    static char Observer;

    if (!objc_getAssociatedObject(self.textView, &Observer)) {
        objc_setAssociatedObject(self.textView, &Observer, @YES, OBJC_ASSOCIATION_RETAIN);

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetLocalCenter(),
            NULL, FilePathHighlighter_Handler,
            (CFStringRef)NSTextStorageDidProcessEditingNotification,
            self.textView.textStorage, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}
@end
