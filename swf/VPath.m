//
//  VPath.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/24.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VPath.h"

#import "VEdge.h"

@implementation VPath


- (id)init 
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithEdges:(NSMutableArray *)edges withRightFill:(BOOL)_isRightFill
{
    self = [self init];
    canvasStr = [[NSMutableString alloc] init];
    
    //edgeList = [[NSMutableArray alloc] initWithArray:edges];
    edgeList = edges;   // We own the edges now. caller should not free it.
    //NSLog(@"edgeList count = %d", [edgeList count]);
    //[edgeList retain];
    reversed = !_isRightFill;
    return self;
}

- (void)dealloc
{
    // TODO:
    [edgeList removeAllObjects];    // all the VEdge in the list are free now.
    [edgeList release];
    [canvasStr release];    // TODO
    [super dealloc];
}

- (BOOL)isRightFill
{
    return !reversed;
}

- (CGPoint)startPoint
{
    if (reversed) { // left fill edges in reversed order
        VEdge *lastEdge = [edgeList lastObject];
        return lastEdge.endPoint;
    } else {        // normal right fill edges
        VEdge *firstEdge = [edgeList objectAtIndex:0];
        return firstEdge.startPoint;
    }
}

- (CGPoint)endPoint
{
    if (reversed) { // left fill edges in reversed order
        VEdge *firstEdge = [edgeList objectAtIndex:0];
        return firstEdge.startPoint;
    } else {        // normal right fill edges
        VEdge *lastEdge = [edgeList lastObject];
        return lastEdge.endPoint;
    }
}

- (NSString *)drawInContext:(CGContextRef)ctx
{
    CGPoint startP;
    if (reversed) { // this seems never be called, since only line stroke will call this function.
                    // all the line stoke is set to right fill (so is always not reversed).
                    // TODO: keep it so far.. maybe useful in other usage.
        
        VEdge *lastEdge = [edgeList lastObject];

        startP = lastEdge.endPoint;
        CGContextMoveToPoint(ctx, startP.x, startP.y);
        [canvasStr appendFormat:@"moveTo(%.3f, %.3f);\n", startP.x, startP.y];
        
        for (uint i = ([edgeList count] - 1); i >= 0; i--) {
            VEdge *e = [edgeList objectAtIndex:i];
            [canvasStr appendString:[e drawInContext:ctx withReversed:reversed]];
        }        
        
    } else {
        VEdge *firstEdge = [edgeList objectAtIndex:0];
        
        startP = firstEdge.startPoint;
        CGContextMoveToPoint(ctx, startP.x, startP.y);
        [canvasStr appendFormat:@"moveTo(%.3f, %.3f);\n", startP.x, startP.y];
        
        for (uint i = 0; i < [edgeList count]; i++) {
            VEdge *e = [edgeList objectAtIndex:i];
            [canvasStr appendString:[e drawInContext:ctx withReversed:reversed]];
        }
        
    }
    return canvasStr;
}

- (NSString *)draw2InContext:(CGContextRef)ctx
{
    if (reversed) {
        for (int i = ([edgeList count] - 1); i >= 0; i--) {
            VEdge *e = [edgeList objectAtIndex:i];
            [canvasStr appendString:[e drawInContext:ctx withReversed:reversed]];
        }        
    } else {
        for (int i = 0; i < [edgeList count]; i++) {
            VEdge *e = [edgeList objectAtIndex:i];
            [canvasStr appendString:[e drawInContext:ctx withReversed:reversed]];
        }        
    }
    
    return canvasStr;
}

@end
