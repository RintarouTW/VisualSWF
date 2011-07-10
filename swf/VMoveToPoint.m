//
//  VNonEdge.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/27.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VMoveToPoint.h"


@implementation VMoveToPoint

@synthesize moveTo, delta,from;

- (id)initWithMoveToPoint:(CGPoint)theMoveToPoint
{
    self = [super init];
    if (self) {
        moveTo.x = theMoveToPoint.x / TWIPS_PER_PIXEL;
        moveTo.y = theMoveToPoint.y / TWIPS_PER_PIXEL;
    }
    return self;
}

- (void)drawInPath:(CGMutablePathRef)thePath withTransform:(CGAffineTransform *)affineTransform
{
    /* from, delta calculation */
    if (CGPathIsEmpty(thePath)) {
        delta = moveTo;
        from = CGPointMake(0, 0);
    } else {
        from = CGPathGetCurrentPoint(thePath);
        delta.x = moveTo.x - from.x;
        delta.y = moveTo.y - from.y;
    }
    
    CGPathMoveToPoint(thePath, affineTransform, moveTo.x, moveTo.y);
}

- (void)drawInContext:(CGContextRef)ctx shouldShowDelta:(BOOL)toShowDelta
{
}

@end
