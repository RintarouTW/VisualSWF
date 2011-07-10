//
//  F2CAppDelegate.m
//  F2C
//
//  Created by Rintarou on 2011/2/7.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "F2CAppDelegate.h"

//#define DEV_MODE    1

@implementation F2CAppDelegate

@synthesize window, aboutWindow, f2cViewController, appVersion;

/* DEVELOP MODE only */

#ifdef DEV_MODE
- (id)init {
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject: [NSNumber numberWithBool:YES] forKey:@"WebKitDeveloperExtras"]];
    }
    return self;
}
#endif // DEV_MODE

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application

#ifdef DEBUG
    // fast testing for debug
    //[f2cViewController openFile:"/Users/rintarou/Projects/swfparser/trunk/clips/trip.swf"];
    //[f2cViewController openFile:"/Users/rintarou/Projects/swfparser/trunk/clips/test2.swf"];     // has DefineMorph2
    //[f2cViewController openFile:"/Users/rintarou/Projects/swfparser/trunk/clips/Baum.swf"];
    //[f2cViewController openFile:"/Users/rintarou/Projects/swfparser/trunk/clips/download/s014_boom_ep2.swf"];
    [f2cViewController openFile:"/Users/rintarou/Projects/swfparser/trunk/clips/blue.swf"];
    //[f2cViewController openFile:"/Users/rintarou/Projects/swfparser/trunk/clips/font.swf"];        // JPEG
    return;
#endif  // DEBUG
    [window setRepresentedURL:[NSURL fileURLWithPath:@"F2C"]];
    self.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [window setTitle:[NSString stringWithFormat:@"  %@", appVersion]];
    [[window standardWindowButton:NSWindowDocumentIconButton] setImage:[NSImage imageNamed:@"NSApplicationIcon"]];
    [f2cViewController openDocument:self];
    return;
    
}


- (IBAction)openAboutWindow:(id)sender
{
    [aboutWindow setIsVisible:YES];
}


// NSApplicationDelegate protocol
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}


@end
