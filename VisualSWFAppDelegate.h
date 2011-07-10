//
//  VisualSWFAppDelegate.h
//  
//
//  Created by Rintarou on 2010/12/26.
//  Copyright 2010 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"
#import <Cocoa/Cocoa.h>

#import "HostViewController.h"

#import "CanvasCodeViewController.h"


@interface VisualSWFAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
    NSWindow *window;
    HostViewController *hostViewController;
    CanvasCodeViewController *canvasCodeViewController;
    NSMenuItem *canvasCodeWindowItem;
    NSWindow *aboutWindow;
    
    // UI Bindings
    uint        numTables;
    uint        numTags;
    uint        maxDepth;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *aboutWindow;
@property (assign) IBOutlet NSMenuItem *canvasCodeWindowItem;
@property (assign) uint     numTables;
@property (assign) uint     numTags;
@property (assign) uint     maxDepth;


- (IBAction)openDocument:(id)sender;
- (IBAction)canvasCodeWindowSwitch:(id)sender;
- (IBAction)openAboutWindow:(id)sender;

- (void)windowWillClose:(NSNotification *)notification;

- (void)reloadHostViewController;

@end
