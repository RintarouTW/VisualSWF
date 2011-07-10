//
//  VArrow.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/27.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VArrow.h"


@implementation VArrow

@synthesize width, length;

// Use default setting without construct a new object instance.
// easy for caller who just want to draw an arrow.
+ (void)drawInPath:(CGMutablePathRef)thePath withVector:(CGPoint)theVector
{
    CGFloat deltaX = theVector.x;
    CGFloat deltaY = theVector.y;
    
    CGPoint n = CGPointMake(-deltaY, deltaX);   // normal vector of (deltaX, deltaY)
    n = [Shared normalizeVector:n withLength:ARROW_WIDTH/2];
    
    CGPoint a = CGPointMake(deltaX, deltaY);
    a = [Shared normalizeVector:a withLength:ARROW_LENGTH];
    
    CGPoint cp = CGPathGetCurrentPoint(thePath);
    
    /* draw in extended mode by default */
    a.x = cp.x - a.x;
    a.y = cp.y - a.y;
    CGPathAddLineToPoint(thePath, nil, a.x + n.x, a.y + n.y);
    CGPathAddLineToPoint(thePath, nil, a.x - n.x, a.y - n.y);
    CGPathAddLineToPoint(thePath, nil, cp.x, cp.y);        
}

+ (void)drawInContext:(CGContextRef)ctx withVector:(CGPoint)theVector
{
    CGFloat deltaX = theVector.x;
    CGFloat deltaY = theVector.y;
    
    CGPoint n = CGPointMake(-deltaY, deltaX);   // normal vector of (deltaX, deltaY)
    n = [Shared normalizeVector:n withLength:ARROW_WIDTH/2];
    
    CGPoint a = CGPointMake(deltaX, deltaY);
    a = [Shared normalizeVector:a withLength:ARROW_LENGTH];
    
    CGPoint cp = CGContextGetPathCurrentPoint(ctx);
    
    /* draw in extended mode by default */
    a.x = cp.x - a.x;
    a.y = cp.y - a.y;
    CGContextAddLineToPoint(ctx, a.x + n.x, a.y + n.y);
    CGContextAddLineToPoint(ctx, a.x - n.x, a.y - n.y);
    CGContextAddLineToPoint(ctx, cp.x, cp.y);
}

- (id)initWithVector:(CGPoint)theVector andExtendedMode:(BOOL)extendedMode
{
    self = [super init];
    if (self) {
        // Init
        width  = ARROW_WIDTH;
        length = ARROW_LENGTH;
        directedVector = theVector;
        isExtendedMode = extendedMode;
    }
    return self;
}


- (void)drawInPath:(CGMutablePathRef)thePath withTransform:(CGAffineTransform *)affineTransform
{
    CGFloat deltaX = directedVector.x;
    CGFloat deltaY = directedVector.y;

    CGPoint n = CGPointMake(-deltaY, deltaX);   // normal vector of (deltaX, deltaY)
    n = [Shared normalizeVector:n withLength:ARROW_WIDTH/2];
    
    CGPoint a = CGPointMake(deltaX, deltaY);
    a = [Shared normalizeVector:a withLength:ARROW_LENGTH];
    
    CGPoint cp = CGPathGetCurrentPoint(thePath);
    
    if (!isExtendedMode) {
        a.x = cp.x - a.x;
        a.y = cp.y - a.y;
        CGPathAddLineToPoint(thePath, affineTransform, a.x + n.x, a.y + n.y);
        CGPathAddLineToPoint(thePath, affineTransform, a.x - n.x, a.y - n.y);
        CGPathAddLineToPoint(thePath, affineTransform, cp.x, cp.y);        
    } else {
        a.x = cp.x + a.x;
        a.y = cp.y + a.y;
        CGPathMoveToPoint(thePath,    affineTransform, a.x, a.y);
        CGPathAddLineToPoint(thePath, affineTransform, cp.x + n.x, cp.y + n.y);
        CGPathAddLineToPoint(thePath, affineTransform, cp.x - n.x, cp.y - n.y);
        CGPathAddLineToPoint(thePath, affineTransform, a.x, a.y);
    }
}

@end
