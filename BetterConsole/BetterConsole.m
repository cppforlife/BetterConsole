#import "BetterConsole.h"
#import "BCFilePathHighlighter.h"
#import "BCFilePathNavigator.h"
#import "BCColorHighlighter.h"

@interface BetterConsole (BCClassDump)
- (id)editorArea;
- (id)activeDebuggerArea;
- (id)consoleArea;
@end

@implementation BetterConsole

+ (void)pluginDidLoad:(NSBundle *)plugin {
	static id sharedPlugin = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		sharedPlugin = [[self alloc] init];
	});
}

- (id)init {
	if (self = [super init]) {
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(windowDidBecomeKey:)
            name:NSWindowDidBecomeKeyNotification object:nil];
	}
	return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
	[self _hookIntoConsole];
}

- (void)_hookIntoConsole {
    NSTextView *textView = self._currentConsoleView;
    if (!textView) return;

    [BCFilePathHighlighter attachToTextView:textView];
    [BCColorHighlighter attachToTextView:textView];
    [BCFilePathNavigator attachToTextView:textView];
}

- (id)_currentWorkspaceController {
    id workspaceController = [[NSApp keyWindow] windowController];
    if ([workspaceController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        return workspaceController;
    }
    return nil;
}

- (NSTextView *)_currentConsoleView {
    id workspaceController = self._currentWorkspaceController;
    id editorArea = [workspaceController editorArea];
    id activeDebuggerArea = [editorArea activeDebuggerArea];
    id consoleArea = [activeDebuggerArea consoleArea];
    return (NSTextView *)[consoleArea valueForKeyPath:@"_consoleView"];
}
@end