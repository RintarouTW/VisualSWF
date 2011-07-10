//
//  RootLayerDelegate.m
//  
//
//  Created by Rintarou on 2010/12/26.
//  Copyright 2010 http://rintarou.dyndns.org. All rights reserved.
//



#import "RootLayer.h"
#import "Column.h"

#define COLUMN_LEFT_PADDING 100
#define COLUMN_WIDTH        700

@implementation RootLayer

@synthesize width, height, clickPoint;


- (id) init {
    self = [super init];
    if (self) {
        // Initialization code here.
        //self.geometryFlipped = YES;
        columns = [[NSMutableArray alloc] init];
        //[self removeAllAnimations];
        //[self setBounds:CGRectMake(0, 0, 1000, 1000)];
        /*
        CGRect myFrame = [self frame];
        NSLog(@"myFrame origin (%f, %f)", myFrame.origin.x, myFrame.origin.y);
        myFrame.origin.x = 0;
        myFrame.origin.y = 0;
        [self setFrame:myFrame];
         */
        //[self setAnchorPoint:CGPointMake(0, 0)]; 
    }
    return self;    
}

- (void)dealloc {
//    NSLog(@"RootLayer is deallocated");
    [columns removeAllObjects];
    [columns release];
    [super dealloc];
}

- (void)addTable:(TableLayer *)table atColumn:(uint)col {
    Column *column = nil;
    
    /* try to find if the column exist */
    if ([columns count] > col) {
        column = [columns objectAtIndex:col];
    } else {
        /* create new column */
        column = [[Column alloc] init];
        column.frameX = col * COLUMN_WIDTH + COLUMN_LEFT_PADDING;
        [columns addObject:column];
        [column release]; // now it's owned by columns
        width = column.frameX + COLUMN_WIDTH;
    }
    
    /* add table to the column indexed by col */
    [column addTable:table];
    [self addSublayer:table];
    
    //NSLog(@"RootLayer contentsRect = %f, %f", [self contentsRect].size.width, [self contentsRect].size.height);
    
    /* update bounds height */
    // Do not update the bounds, just update width and height only.
    // Since it will be too big and cost a lot of memory even without drawing anything.
    
    if (column.lastTableBottom > height) {
        height = column.lastTableBottom;        
    }
    
    /* set dirty bit */
    [table setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx 
{    
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);
    CGContextFillRect(ctx, [self bounds]);
    CGContextSetRGBFillColor(ctx, 0, 0, 1, 1);
    CGContextFillRect(ctx, CGRectMake(clickPoint.x, clickPoint.y, 100, 100));
}

@end
