//
//  Traverser.m
//  
//
//  Created by Rintarou on 2011/1/17.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Traverser.h"

#ifdef __cplusplus
#include "sys/time.h"
#endif


@implementation ChildItem

@synthesize ownerTable, rowInOwnerTable, vobjectOfTable;

@end

@implementation Traverser

@synthesize delegate, maxDepth, previewableTagOnly;

@synthesize numTables, numTags, numArrays, numObjects, numPrimitiveValues;

- (id) init
{
    self = [super init];
    if (self) {
        maxDepth            = TRAVERSER_MAX_DEPTH - 1;      // start from 0
        previewableTagOnly  = TRAVERSER_PREVIEWABLE_ONLY;
    }
    return self;
}

- (void) dealloc
{
    //NSLog(@"Traverser dealloc");
    [super dealloc];
}

- (void)stopTraverse
{
    //NSLog(@"stopTraverse");
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
        //NSLog(@"timer invalidated");
    }    
}

- (void)pushToNextList:(ChildItem *)childItem
{
    if (!nextList) {
        nextList = new VList();
    }
        
    nextList->push(childItem);
}


// VObject with primitive type value is not called by this function.
// They are handled inside the function.

- (void)traverseObject:(VObject *)vobj withOwnerTable:(TableLayer *)ownerTable atRow:(uint) rowInOwnerTable
{   
    // skip SHPAE Object.
    /*
    static std::string str = "SHAPE";
    if (str.compare(vobj->getTypeInfo()) == 0)
        return;
     */

    
    numTables++;
    
    //NSLog(@"Traverse Table %d", numTables);
    
    /////////////////////////////////////////////////////////////
    // Table Allocation for this vobj
    TableLayer *table = [[TableLayer alloc] init];
    
    if (!table) {
        // memory error
        NSLog(@"memory allocation error");
        abort();
    }
    // get the type info as the header of the Table
    table.header = vobj->getTypeInfo();
    table.vobject = vobj;
    table.ownerTable = ownerTable;
    table.rowInOwnerTable = rowInOwnerTable;
    
    // use VObject's reserved to back reference to TableLayer.
    vobj->reserved = table;
    
    /////////////////////////////////////////////////////////////
    
    PropertyList *plist = vobj->getPropertyList();
    
    for (std::vector<Property>::iterator it = plist->begin(); it != plist->end(); it++) {
        
        VObject *value = it->value;
        
        /// Primitive Value ///
        if (value->isValue()) {
            numPrimitiveValues++;
            value->reserved = table;    // back reference to Table.
            [table appendRow:it->name.c_str() andValue:value->toString()];
            continue;
        }
        
        
        /// Object Value ///
        if (value->isObject()) {
            uint numRow = [table appendRow:it->name.c_str() andValue:value->getTypeInfo()];
            
            ChildItem *childItem = [[ChildItem alloc] init];    // will be released by traveseList:
            childItem.ownerTable = table;
            childItem.vobjectOfTable = value;
            childItem.rowInOwnerTable = numRow;
            [self pushToNextList:childItem];
            
            continue;
        }
        
        /// Array Value ///
        if (value->isArray()) {
            numArrays++;
            value->reserved = table;    // back reference to Table.
            
            PropertyList *plistOfArray = value->getPropertyList();
            
            for (std::vector<Property>::iterator array_it = plistOfArray->begin(); array_it != plistOfArray->end(); array_it++) {

                std::string fullArrayItemName;
                fullArrayItemName = it->name + "[";
                fullArrayItemName += array_it->name + "]";
                
                VObject *array_value = array_it->value;
                if (array_value->isValue()) {
                    numPrimitiveValues++;
                    [table appendRow:fullArrayItemName.c_str() andValue:array_value->toString()];
                }
                
                if (array_value->isObject()) {
                    uint numRow = [table appendRow:fullArrayItemName.c_str() andValue:array_value->getTypeInfo()];
                    
                    ChildItem *childItem = [[ChildItem alloc] init];
                    childItem.ownerTable = table;
                    childItem.vobjectOfTable = array_value;
                    childItem.rowInOwnerTable = numRow;
                    
                    [self pushToNextList:childItem];
                }
                
                if (array_value->isArray()) {
                    fprintf(stderr, "is Array : (Something wrong? an array can hold another array?)\n");
                    abort();
                }
            }
            
            continue;
        }
        
    }
    
    [delegate tableComplete:table atDepth:depth];
}


- (void)startTraverseTimer
{
    // ##### Bug code since it will retain Traverser. Try to use new NSInvokation to do this job.
    // timer to call traverseList
    timer = [NSTimer scheduledTimerWithTimeInterval:TRAVERSER_TIMER_INTERVAL target:self selector:@selector(traverseList:) userInfo:nil repeats: NO];
}


- (suseconds_t)getCurrentTime
{
    timeval tim;
    gettimeofday(&tim, NULL);
    return tim.tv_usec;
}

- (void)traverseList:(NSTimer *)theTimer
{
    //NSLog(@"traverseList");
    suseconds_t startTime, now;
    startTime = [self getCurrentTime];
    
    //NSLog(@"currentTime = %f", startTime);
    
    while (!currentList->empty()) {
        
        ChildItem *currentItem = currentList->front();
        [self traverseObject:currentItem.vobjectOfTable withOwnerTable:currentItem.ownerTable atRow:currentItem.rowInOwnerTable];
        [currentItem release]; // ok to be free.
        currentList->pop();
        
        //If over timeslice then break and wait for next timer fire up.
        now = [self getCurrentTime];
        if ((now - startTime) > TRAVERSER_PARSE_TIME_SLICE) {
            break;
        }
        
        if (numTables >= TRAVERSER_TABLE_LIMIT) {
            break;
        }
    }
    
    if (numTables >= TRAVERSER_TABLE_LIMIT) {
        NSLog(@"too many tables, stop..");
        // Clean the memory.
        // Delete the items in both currentList and nextList.
        while(!currentList->empty()) {
            ChildItem *item = currentList->front();
            [item release];
            currentList->pop();
        }
        delete currentList;
        currentList = NULL;
        while(nextList && (!nextList->empty())) {
            ChildItem *item = nextList->front();
            [item release];
            nextList->pop();
        }        
        delete nextList;
        nextList = NULL;
        [delegate traverseComplete];
        return;
    }
    
    if (currentList->empty()) {
        // release currentList since it's parsed.
        delete currentList;
        currentList = NULL;
        
        if (nextList) {
            currentList = nextList;
            nextList = NULL;
            depth++;
            if (depth > maxDepth) {
                //NSLog(@"numTables = %d", numTables);
                //NSLog(@"-- Traversing done --");
                [delegate traverseComplete];
                return;
            }
            
        } else {            
            //NSLog(@"numTables = %d", numTables);
            //NSLog(@"numArrays = %d", numArrays);
            //NSLog(@"numPrimitiveValues = %d", numPrimitiveValues);
            //NSLog(@"-- Traversing completed --");
            [delegate traverseComplete];
            return;
        }
    }
    
    [self startTraverseTimer];
}



- (void)BFSTraverse:(VObject *)vobj
{	
    if (!vobj) {
        return;
    }
    
    //////////////////////////
    // BFS Traverse
    
    currentList = new VList();
        
    ChildItem *rootItem = [[ChildItem alloc] init];
    rootItem.ownerTable = nil;  // means this is the root
    rootItem.vobjectOfTable = vobj;
    
    // push root into currentList
    currentList->push(rootItem);

    //NSLog(@"-- Traversing start --");
    [self startTraverseTimer];
    
    // END of BFS Traverse
    //////////////////////////
}



- (void)traverseTagsOnly:(VObject *)vobj
{
    if (!vobj) {
        return;
    }
    
    currentList = new VList();
    maxDepth = 0;
    
    VObject &tags = (*vobj)["Tags"];
    
    numTags = tags.length();
    
    for (int i = 0; i < numTags; i++) {
#ifdef F2C
        const char *header = tags[i].getTypeInfo();
        //NSLog(@"header = %s", header);
        if ((strcmp(header, "DefineShape") != 0) &&
            (strcmp(header, "DefineShape2") != 0) &&
            (strcmp(header, "DefineShape3") != 0) &&
            (strcmp(header, "DefineShape4") != 0) 
#ifdef DEBUG    // under development
            &&
            (strcmp(header, "SetBackgroundColor") != 0) &&
            (strcmp(header, "DefineBits") != 0) &&
            (strcmp(header, "JPEGTables") != 0) &&
            (strcmp(header, "DefineBitsJPEG2") != 0) &&
            (strcmp(header, "DefineBitsJPEG3") != 0) &&
            (strcmp(header, "DefineBitsJPEG4") != 0) &&
            (strcmp(header, "DefineBitsLossless") != 0) &&
            (strcmp(header, "DefineBitsLossless2") != 0)
#endif // DEBUG
            ) {
            continue;
        }
#endif // F2C
        
        
        ChildItem *tagItem = [[ChildItem alloc] init];
        tagItem.ownerTable = nil;
        tagItem.vobjectOfTable = &tags[i];
        
        // push root into currentList
        currentList->push(tagItem);
        
    }
    [self startTraverseTimer];
    
}

@end
