//
//  Traverser.h
//
//  Traverser will traverse the VObject tree and create the table for the Object typed VObject.
//  It's using BFS traverse and a timer for non blocking the user interface(main thread).
//  Convert from VObject space to [Table, Array, Primitive Value] space. Also create links(mapping) between them.
//
//  Created by Rintarou on 2011/1/17.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>

#import "TableLayer.h"

#ifdef __cplusplus
#include "VObject.h"
#include <queue>
#endif // __cplusplus

@interface ChildItem : NSObject
{
    TableLayer *ownerTable;
    uint rowInOwnerTable;

#ifdef __cplusplus
    VObject *vobjectOfTable;
#endif // __cplusplus


}

@property (assign) TableLayer   *ownerTable;
@property (assign) uint         rowInOwnerTable;


#ifdef __cplusplus
@property (assign) VObject *vobjectOfTable;
#endif // __cplusplus

@end

#ifdef __cplusplus

typedef std::queue<ChildItem *> VList;

#endif // __cplusplus


@protocol TraverserDelegate

- (void)tableComplete:(TableLayer *)table atDepth:(uint) depth;
- (void)traverseComplete;
- (void)gotError:(uint)errorCode;

@end

@interface Traverser : NSObject {

    NSTimer *timer;
    
    id <TraverserDelegate> delegate;
    
#ifdef __cplusplus
    VObject *root;
    VList *currentList;
    VList *nextList;
    unsigned int depth;

#endif  // __cplusplus
    
    uint    maxDepth;
    BOOL    previewableTagOnly;
    
    uint    numTags;
    uint    numObjects;
    
    uint    numTables;
    uint    numArrays;
    uint    numPrimitiveValues;
}

@property (assign) id <TraverserDelegate>   delegate;
@property (readonly) uint                     numTags;
@property (readonly) uint                     numObjects;
@property (readonly) uint                     numTables;
@property (readonly) uint                     numArrays;
@property (readonly) uint                     numPrimitiveValues;
@property (assign) uint                     maxDepth;               // TODO: should be binded with Preference
@property (assign) BOOL                     previewableTagOnly;     // TODO: should be binded with Preference


/// Internal used methods ////
#ifdef __cplusplus
- (void)BFSTraverse:(VObject *)vobj;
- (void)traverseObject:(VObject *)vobj withOwnerTable:(TableLayer *)ownerTable atRow:(uint) rowInOwnerTable;
- (void)pushToNextList:(ChildItem *)childItem;

- (void)traverseTagsOnly:(VObject *)vobj;       // For F2C
#endif // __cplusplus

- (void)stopTraverse;   // stopTraverse must be called before release, in case of timer synchronization.

@end
