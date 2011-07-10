//
//  HostViewController.h
//  
//
//  Created by Rintarou on 2011/1/6.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>
#import "Model.h"
#import "HostView.h"
#import "Traverser.h"



@interface HostViewController : NSObject <TraverserDelegate> {
    Model *model;
    Traverser *traverser;
    HostView *hostView;

    RootLayer *rootLayer;
    LinkLayer *linkLayer;
    TableLayer *lastTable;    // remember the last table for the following appendRow: to use.
    
    id  delegate;             // app delegate who is responsible for the UI.
                              // we also need some information from delegate before parsing.
                              // and we can notify the app delegate some information while parsing.
    
    uint    numTables;
    uint    numTags;
    
    uint    maxDepth;
}

@property (assign) HostView *hostView;
@property (assign) id       delegate;
@property (assign) uint     numTables;
@property (assign) uint     numTags;
@property (assign) uint     maxDepth;


- (BOOL)openFile:(const char *)filename;

//// Implement TraverserDelegate /////
- (void)tableComplete:(TableLayer *)table atDepth:(uint) depth;
- (void)traverseComplete;
- (void)gotError:(uint)errorCode;

@end
