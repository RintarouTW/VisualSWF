//
//  AnchorLayer.m
//  
//
//  Created by Rintarou on 2011/1/17.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "LinkLayer.h"


@implementation LinkLayer

@synthesize rootLayer;

- (id) init {
    self = [super init];
    if (self) {
        // Initialization code here.
        linksArray = [[NSMutableArray alloc] init];
        //[self removeAllAnimations];
    }
    return self;    
}

- (void)dealloc 
{
    [linksArray removeAllObjects];
    [linksArray release];
    [super dealloc];
}

- (Link *)addLinkWithOwnerAnchor:(CGPoint)ownerAnchorPoint andAnchorOnTable:(CGPoint)anchorOfTable
{
    Link *link = [[Link alloc] init];
    link.ownerAnchorPoint = ownerAnchorPoint;
    link.anchorOfTable = anchorOfTable;
    [linksArray addObject:link];
    [link release];
    [self setNeedsDisplay];
    return link;
}

- (void)setFrame:(CGRect)rect
{
    [self setNeedsDisplay];
    [super setFrame:rect];
}

- (void)drawInContext:(CGContextRef)ctx
{    
//    NSLog(@"linksArray count = %d", [linksArray count]);
//    NSLog(@"bounds %f, %f, %f, %f", [self bounds].origin.x, [self bounds].origin.y, [self bounds].size.width, [self bounds].size.height);

    CGContextSetRGBStrokeColor(ctx, 0.2, 0.2, 0.2, 1);    // Link Color
    CGContextBeginPath(ctx);
    for (uint i = 0; i < [linksArray count]; i++) {
        Link *link = [linksArray objectAtIndex:i];
        CGPoint ownerAnchorPoint = [self convertPoint:link.ownerAnchorPoint fromLayer:rootLayer];
        CGPoint anchorOfTable = [self convertPoint:link.anchorOfTable fromLayer:rootLayer];
        
        CGContextMoveToPoint(ctx, ownerAnchorPoint.x, ownerAnchorPoint.y);
        CGContextAddLineToPoint(ctx, anchorOfTable.x, anchorOfTable.y);
    }
    CGContextStrokePath(ctx);
}

@end
