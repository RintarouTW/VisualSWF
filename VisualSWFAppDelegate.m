//
//  VisualSWFAppDelegate.m
//  
//
//  Created by Rintarou on 2010/12/26.
//  Copyright 2010 http://rintarou.dyndns.org. All rights reserved.
//

#import "VisualSWFAppDelegate.h"


@implementation VisualSWFAppDelegate

@synthesize window, aboutWindow, canvasCodeWindowItem;

// Bindings
@synthesize numTables, numTags, maxDepth;

- (void)setMaxDepth:(uint)max
{
    //NSLog(@"max = %d", max);
    maxDepth = max;
    hostViewController.maxDepth = max;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
    
    self.maxDepth = TRAVERSER_MAX_DEPTH;
/*    
    canvasCodeViewController = [[CanvasCodeViewController alloc] initWithNibName:@"CanvasCodeViewController" bundle:nil];
    [canvasCodeViewController loadView];
*/
    
#ifdef DEBUG
    // fast testing for debug
    [self reloadHostViewController];
    //[hostViewController openFile:"/Users/rintarou/Projects/swfparser/trunk/clips/trip.swf"];
    //[hostViewController openFile:"/Users/rintarou/Projects/swfparser/trunk/clips/test2.swf"]; // has DefineMorph2
    //[hostViewController openFile:"/Users/rintarou/Projects/swfparser/trunk/clips/Baum.swf"];
    //[hostViewController openFile:"/Users/rintarou/Projects/swfparser/trunk/clips/t1.swf"];
    //[hostViewController openFile:"/Users/rintarou/Projects/swfparser/trunk/clips/background1.swf"];
    [hostViewController openFile:"/Users/rintarou/Projects/swfparser/trunk/clips/font.swf"];      // JPEG
    return;
#endif  // DEBUG
    

    
    [self openDocument:self];
    return;

}


- (void)reloadHostViewController
{    
    if (hostViewController) {
        [hostViewController release];
    }

    hostViewController = [[HostViewController alloc] init];
    hostViewController.delegate = self;
    hostViewController.maxDepth = maxDepth;

    hostViewController.hostView.previewLayer.canvasCodeViewController = canvasCodeViewController;   // TODO: Must be refined.
    
    [window setContentView:hostViewController.hostView];                        // TODO
    //[[window contentView] addSubview:hostViewController.hostView];            // TODO, has bug while reload, seems memory issue.
    //[hostViewController.hostView setFrame:[[window contentView] bounds]];     // strcmp become bad access.

    [window makeFirstResponder:hostViewController.hostView];                    // TODO
    [window makeKeyWindow];
}

- (IBAction)canvasCodeWindowSwitch:(id)sender
{
    if (sender == canvasCodeWindowItem) {
        if ([canvasCodeViewController.panel isVisible]) {
            [canvasCodeViewController setPanelState:NO];
            [canvasCodeWindowItem setTitle:@"Show Canvas Window"];
        } else {
            [canvasCodeViewController setPanelState:YES];
            [canvasCodeWindowItem setTitle:@"Hide Canvas Window"];
        }        
    }
}

- (IBAction)openAboutWindow:(id)sender
{
    [aboutWindow setIsVisible:YES];
}

- (IBAction)openDocument:(id)sender
{
    int result;
    NSArray *fileTypes = [NSArray arrayWithObject:@"swf"];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    
    [oPanel setAllowsMultipleSelection:NO];
    result = [oPanel runModalForDirectory:NSHomeDirectory()
                                     file:nil types:fileTypes];
    if (result == NSOKButton) {
        [self reloadHostViewController];
        
        NSArray *filesToOpen = [oPanel filenames];
        NSString *aFile = [filesToOpen objectAtIndex:0];
        if (![hostViewController openFile:[aFile UTF8String]]) {
            [window setContentView:nil];
            [hostViewController release];
            hostViewController = nil;
        }
    }
}

// NSApplicationDelegate protocol
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

// NSWindowDelegate protocol
- (void)windowWillClose:(NSNotification *)notification
{
    [canvasCodeViewController.panel performClose:self];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    //[window makeFirstResponder:hostViewController.hostView];
    //[window makeKeyWindow];
    //NSLog(@"main window did become key");
}

/* TODO: UserDefaults
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
}
 */

@end
