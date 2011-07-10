//
//  CATableLayerDelegate.h
//  
//
//  Created by Rintarou on 2010/12/26.
//  Copyright 2010 http://rintarou.dyndns.org. All rights reserved.
//


#import "Share.h"

#import <Cocoa/Cocoa.h>

#import "Link.h"


#ifdef __cplusplus
#include "VObject.h"
#endif // __cplusplus


#import "Previewable.h"

@interface TableRow : NSObject
{
    
    //const char *name;
    NSString *myName;   // store full name (since array's name)
    const char *value;
    TableRow *prev;
}

@property (assign) const char *name;
@property (assign) const char *value;
@property (assign) TableRow *prev;

@end

@interface TableLayer : CALayer {
    // Relations
    TableLayer *ownerTable;
    uint rowInOwnerTable;
    Link *myLink;
    NSMutableArray *children;
    TableLayer *nextTable;  // This is the next Table in Column, it may not be a sibling.
    // above should be in TableLayerControler (Not implemented yet) since it becomes more complicated now.
    // These are almost UI un-related handling.

    const char *header;
    TableRow *lastRow;
    uint maxNameLength;
    uint maxValueLength;
    uint numRows;
    
    CGPoint anchorPoint;    // Link to the row of the owner table in RootLayer's coordinate.
    int focusedRowNum;
    id <StepPreviewer> previewer;               // knows who is my previewer.
    
#ifdef __cplusplus
    VObject *vobject;           // Which the table is represented for.
#endif // __cplusplus

}

@property (assign) TableLayer *ownerTable;
@property (assign) uint rowInOwnerTable;
@property (assign) Link *myLink;
@property (assign) TableLayer *nextTable;
@property (assign) id <StepPreviewer> previewer;


@property (assign) const char *header;
@property (readonly) uint numRows;

#ifdef __cplusplus
@property (assign) VObject *vobject;
#endif // __cplusplus

// Row data handling
- (uint)appendRow:(const char *)pName andValue:(const char *)pValue;

// Tree Releations for layout
- (void)addChild:(TableLayer *)child;

- (void)onFocused;
- (void)lostFocus;
- (TableLayer *)tableOfFocusedRow;

- (CGPoint)getAnchorPointOnRow:(uint)rowNum;    // the anchor point of the row in RootLayer's coordinate.                                                                                                          
- (CGPoint)getAnchorPoint;                      // the anchor point of this table in RootLayer's coordinate.

- (void)mouseMove:(CGPoint)mouseLocation;       // when mouse location is in the table. got notified from HostView.
- (void)rightMouseDown:(CGPoint)mouseLocation;

- (void)drawInContext:(CGContextRef)ctx;

@end
