//
//  F2CAppDelegate.h
//  F2C
//
//  Created by Rintarou on 2011/2/7.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "F2CViewController.h"

@interface F2CAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate> {
    NSWindow   *window;
    NSWindow   *aboutWindow;
    
    /* Controller */
    F2CViewController  *f2cViewController;
    
    NSString    *appVersion;
}

@property (assign) IBOutlet NSWindow   *window;
@property (assign) IBOutlet NSWindow   *aboutWindow;

@property (assign) IBOutlet F2CViewController  *f2cViewController;

@property (assign) NSString *appVersion;

- (IBAction)openAboutWindow:(id)sender;

@end
