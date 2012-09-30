#import "BCColorHighlighter.h"
#import "BCUtils.h"
#import <objc/runtime.h>

@implementation BCColorHighlighter

+ (void)attachToTextView:(NSTextView *)textView {
    static char Observer;

    if (!objc_getAssociatedObject(textView, &Observer)) {
        objc_setAssociatedObject(textView, &Observer, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN);

        CFNotificationCenterAddObserver(
            CFNotificationCenterGetLocalCenter(),
            NULL, BCColorHighlighter_Handler,
            (CFStringRef)NSTextStorageDidProcessEditingNotification,
            textView.textStorage, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}

NSColor *BCColorHighlighter_ColorByKey(NSString *key) {
    static NSMutableDictionary *colorMap = nil;
    if (!colorMap) {
        colorMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            [NSColor colorWithSRGBRed:159.0/255 green:44.0/255  blue:27.0/255  alpha:1], @"40;31m", // red
            [NSColor colorWithSRGBRed:60.0/255  green:189.0/255 blue:16.0/255  alpha:1], @"40;32m", // green
            [NSColor colorWithSRGBRed:172.0/255 green:172.0/255 blue:34.0/255  alpha:1], @"40;33m", // yellow
            [NSColor colorWithSRGBRed:61.0/255  green:187.0/255 blue:200.0/255 alpha:1], @"40;36m", // cyan
        nil];
    }
    return [colorMap objectForKey:key];
}

NS_INLINE void BCColorHighlighter_HideString(NSTextStorage *textStorage, NSRange range) {
    [textStorage addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Arial" size:0.00000000001] range:range];
}

void BCColorHighlighter_Highlight(NSTextStorage *textStorage) {
    NSString *text = textStorage.string;
    NSUInteger startIndex = 0;
    NSUInteger textLength = text.length;

    NSRange head;
    const short
        headLength = 3,  // \033[0
        pivotLength = 1, // m or ;
        tailLength = 6,  // colorKey (eg 40;31m)
        bodyLength = headLength + pivotLength,
        fullLength = bodyLength + tailLength;

    NSString *headMarker = @"\033[0";
    NSColor *currentColor = nil;

    [textStorage beginEditing];
    while (true) {
        head = [text
            rangeOfString:headMarker
            options:NSLiteralSearch
            range:NSMakeRange(startIndex, textLength - startIndex)];

        if ((head.location == NSNotFound) ||
            (head.location + bodyLength > textLength))
            break;

        unichar colorPivot = [textStorage.string characterAtIndex:head.location + headLength];

        // '\033[0m' (reset color) -> hide & highlight up to here
        if (colorPivot == 'm') {
            BCColorHighlighter_HideString(textStorage, NSMakeRange(head.location, bodyLength));

            if (currentColor) {
                [textStorage
                    addAttribute:NSForegroundColorAttributeName value:currentColor
                    range:NSMakeRange(startIndex, head.location - startIndex)];
                currentColor = nil;
            }
        }
        // '\033[0;______' (some color) -> hide & remember
        else if (colorPivot == ';') {
            if (head.location + fullLength > textLength)
                break;

            NSString *colorKey = [text substringWithRange:
                NSMakeRange(head.location + bodyLength, tailLength)];

            if ((currentColor = BCColorHighlighter_ColorByKey(colorKey)) != nil) {
                BCColorHighlighter_HideString(textStorage, NSMakeRange(head.location, fullLength));
            }
        }
        startIndex = head.location + bodyLength + (colorPivot == ';' ? tailLength : 0);
    }
    [textStorage endEditing];
}

void BCColorHighlighter_Handler(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    BCTimeLog(@"BetterConsole - ColorHightlighter") {
        NSTextStorage *textStorage = (NSTextStorage *)object;
        BCColorHighlighter_Highlight(textStorage);
    }
}
@end

