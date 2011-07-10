//
//  HostViewController.m
//  
//
//  Created by Rintarou on 2011/1/6.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "HostViewController.h"



@implementation HostViewController

@synthesize hostView, delegate;

// For App Delegate UI Binding
@synthesize numTables, numTags;

// Set by App Delegate
// Traverser will read this value to be it's maxDepth.
@synthesize maxDepth;

- (id) init 
{
    self = [super init];
    if (self) {
        // Init hostView
        hostView = [[HostView alloc] init];
        
        rootLayer = hostView.rootLayer;
        linkLayer = hostView.linkLayer;
        
        // Init model
        model = [[Model alloc] init];
        
        // Init traverser
        traverser = [[Traverser alloc] init];
        traverser.delegate = self;  // since we implement ModelDelegate protocol
        
        self.maxDepth = TRAVERSER_MAX_DEPTH;
    }
    return self;
}

- (void)dealloc
{
    if ([traverser retainCount] > 1)
        [traverser stopTraverse];   // This must be called to release the timer which retains the Traverser too.
    [traverser release];
    [model release];
    [hostView release];
    [super dealloc];
}

- (void)setNumTables:(uint)num
{
    numTables = num;
    [delegate setNumTables:num];
}

- (void)setNumTags:(uint)num
{
    numTags = num;
    [delegate setNumTags:num];
}

- (void)setMaxDepth:(uint)max
{
    maxDepth = max;
    traverser.maxDepth = max - 1;
}


/////////////////////////////////////////////////////////////////////////////////////
// Method called by UI
/////////////////////////////////////////////////////////////////////////////////////
- (BOOL)openFile:(const char *)filename
{
    BOOL ok = [model parseFile:filename];
    if (ok) {
        self.numTags = model.numTags;
        
#ifdef VisualSWF
        if (model.numObjects > TRAVERSER_TABLE_LIMIT) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert addButtonWithTitle:@"Cancel"];
            [alert setMessageText:[NSString stringWithFormat:@"There are too %d tables ! Continue?", model.numObjects]];
            [alert setInformativeText:[NSString stringWithFormat:@"Show %d tables only to prevent running out of your memory.", TRAVERSER_TABLE_LIMIT]];
            [alert setAlertStyle:NSWarningAlertStyle];
            
            if ([alert runModal] != NSAlertFirstButtonReturn) {
                 // Cancel clicked
                [alert release];                
                return NO;
                
            }
            [alert release];
        }
                
        [traverser BFSTraverse:model.root];
#endif // VisualSWF
        

#ifdef F2C
        [traverser traverseTagsOnly:model.root];
#endif // F2C
    }
    
    return ok;
}



/////////////////////////////////////////////////////////////////////////////////////
// Implement TraverserDelegate, respond to the parser.
/////////////////////////////////////////////////////////////////////////////////////
- (void)tableComplete:(TableLayer *)table atDepth:(uint) depth
{
    if (!table) {
        NSLog(@"tableComplete error");
        abort();
    }
    
    self.numTables++;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    
    [rootLayer addTable:table atColumn:depth];
    
    // after table was added into column, the true anchor point was decided.
    // since the table frame will be fixed.
    // get the anchor point on each row and change to RootLayer's coordination.
    
    // Now it's ok to create the link between this table and it's owner table.
    TableLayer *ownerTable = table.ownerTable;
    if (ownerTable) {
        table.myLink = [linkLayer addLinkWithOwnerAnchor:[ownerTable getAnchorPointOnRow:table.rowInOwnerTable] andAnchorOnTable:[table getAnchorPoint]];
    }
    
    [CATransaction commit];
    [lastTable release];    // now lastTable was owned by rootLayer
}

- (void)traverseComplete
{
    [hostView checkViewRange:YES];
}

- (void)gotError:(uint)errorCode
{
    // TODO: Error Handling
}
/////////////////////////////////////////////////////////////////////

@end
