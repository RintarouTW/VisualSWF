//
//  HostView.h
//  
//
//  Created by Rintarou on 2010/12/26.
//  Copyright 2010 http://rintarou.dyndns.org. All rights reserved.
//


#import "Share.h"

#import <Cocoa/Cocoa.h>

#import "BackingLayer.h"
#import "RootLayer.h"
#import "LinkLayer.h"
#import "PreviewLayer.h"

@interface HostView : NSView {
    NSPoint lastDragLocation;
    
    BackingLayer *backingLayer;
    LinkLayer *linkLayer;
    PreviewLayer *previewLayer;
    RootLayer *rootLayer;
    
    NSTrackingArea *trackingArea;
    TableLayer *focusedTableLayer;
}

@property (readonly) RootLayer *rootLayer;
@property (readonly) LinkLayer *linkLayer;
@property (readonly) PreviewLayer *previewLayer;

- (void)checkViewRange:(BOOL)disableAnimation;

@end
