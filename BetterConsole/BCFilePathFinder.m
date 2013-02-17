#import "BCFilePathFinder.h"
#import <Cocoa/Cocoa.h>
#import "BCUtils.h"

@interface BCFilePathFinder (BCClassDump)
- (id)representingFilePath;
- (NSString *)pathString;
@end

@implementation BCFilePathFinder

+ (NSString *)findFullFilePathByFileName:(NSString *)fileName {
    NSString *filePath = nil;
    NSString *rootPath = self._searchRootPath;

    NSLog(@"BCFilePathFinder - searching for '%@' in '%@'", fileName, rootPath);

    NSDirectoryEnumerator *dirEnumerator =
        [[NSFileManager defaultManager] enumeratorAtPath:rootPath];

    BCTimeLog(@"BCFilePathFinder - findFullFilePathByFileName:") {
        for (NSString *relativeFilePath in dirEnumerator) {
            // Skip .git in root and *.build dirs
            if ([relativeFilePath characterAtIndex:0] == '.' ||
                [relativeFilePath.pathExtension isEqualToString:@"build"]) {
                [dirEnumerator skipDescendents];
                continue;
            }

            if (![relativeFilePath.pathExtension hasPrefix:@"m"]) continue;

            if ([relativeFilePath.lastPathComponent isEqualToString:fileName]) {
                filePath = [rootPath stringByAppendingPathComponent:relativeFilePath];
                break;
            }
        }
    }
    return filePath;
}

#pragma mark - Project

+ (NSString *)_searchRootPath {
    id workspaceFilePath = [self._currentWorkspace representingFilePath];
    return [[workspaceFilePath pathString] stringByDeletingLastPathComponent];
}

+ (id)_currentWorkspace {
    return [self._currentWorkspaceController valueForKey:@"_workspace"];
}

+ (id)_currentWorkspaceController {
    id workspaceController = [[NSApp keyWindow] windowController];
    if ([workspaceController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        return workspaceController;
    } return nil;
}
@end
