//
//  ColumnView.m
//  
//
//  Created by Rintarou on 2010/12/19.
//  Copyright 2010 http://rintarou.dyndns.org. All rights reserved.
//

#import "Column.h"

@implementation Column

@synthesize frameX, lastTableBottom;

#define TablePaddingBottom 5
#define TablePaddingTop 5

- (id)init {
    self = [super init];
    if (self) {
        rows = [[NSMutableArray alloc] init];
        lastTableBottom = TablePaddingTop;
    }
    return self;
}

- (void)dealloc {
    [rows removeAllObjects]; // since addObject will increase the reference count of TableLayer
    [rows release];
    [super dealloc];
}


- (void)addTable:(TableLayer *)table
{
    // TODO: so far the design is to use grid layout instead of width change.
    // This is the fast try. in order to know how the performance of Core Animation and connect the whole picture(MVC).
    
    /* get the new table's size info */
    //uint table_width = table.frame.size.width;  // TODO: not used until aligned by left edge
    //uint tableHeight = table.frame.size.height;
    TableLayer *lastTable = [rows lastObject];
    lastTable.nextTable = table;
    
    CGRect frameOfTable = [table frame];
    
    //CGPoint position = [table position];
    //position.y = lastTableBottom + (tableHeight / 2);
    //position.x = frameX;
    //[table setPosition:position];
    frameOfTable.origin.x = frameX;
    frameOfTable.origin.y = lastTableBottom;
    [table setFrame:frameOfTable];
    
    CGRect frameOfOwnerTable;
    TableLayer *ownerTable = table.ownerTable;
    if (ownerTable) {
        frameOfOwnerTable = [ownerTable frame];
        
        if (frameOfTable.origin.y < frameOfOwnerTable.origin.y) {
            frameOfTable.origin.y = frameOfOwnerTable.origin.y;
            [table setFrame:frameOfTable];
        }
    }
    
    //lastTableBottom += (tableHeight + TablePaddingBottom + TablePaddingTop);
    lastTableBottom = frameOfTable.origin.y + frameOfTable.size.height + TablePaddingTop;
    
    /* setup position of the table */   // TODO: use frame.origin ? or position ? align by left edge or center?
    
    /*
    if (table_width > maxTableWidth) {
        maxTableWidth = table_width;
    }
     */
    
    
    /* add table to the rows */
    [rows addObject:table];
}

@end
