//
//  VEdge.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/24.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VEdge.h"


@implementation VEdge

@synthesize startPoint, endPoint, controlPoint, delta, isCurve;

- (id)init
{
    self = [super init];
    if (self) {
        previewPath = CGPathCreateMutable();
    }
    return self;
}

- (void)dealloc
{
    CGPathRelease(previewPath);
    [super dealloc];
}

- (void)asLineWithStart:(CGPoint)twipStartPoint andEnd:(CGPoint)twipEndPoint
{
    CGPoint twipControlPoint = CGPointMake((twipEndPoint.x + twipStartPoint.x) / 2, 
                             (twipEndPoint.y + twipStartPoint.y) / 2);

    
    // Convert to curved edge internally. It seems useful for DefineMorphShape.
    // Line Edge now is only difference in "isCurve" flag.
    
    [self asCurveWithStart:twipStartPoint andControl:twipControlPoint andEnd:twipEndPoint];
    isCurve = NO;   // set isCurve to NO 
    delta.x = endPoint.x - startPoint.x;
    delta.y = endPoint.y - startPoint.y;
}


- (void)asCurveWithStart:(CGPoint)twipStartPoint andControl:(CGPoint)twipControlPoint andEnd:(CGPoint)twipEndPoint;
{
    startPoint = twipStartPoint;
    controlPoint = twipControlPoint;
    endPoint = twipEndPoint;
    
#ifdef TURN_TWIPS_TO_PIXEL
    startPoint.x /= TWIPS_PER_PIXEL;
    startPoint.y /= TWIPS_PER_PIXEL;
    controlPoint.x /= TWIPS_PER_PIXEL;
    controlPoint.y /= TWIPS_PER_PIXEL;
    endPoint.x /= TWIPS_PER_PIXEL;
    endPoint.y /= TWIPS_PER_PIXEL;
#endif
    
    delta.x = endPoint.x - controlPoint.x;
    delta.y = endPoint.y - controlPoint.y;    
    isCurve = YES;
    
    ////////////// preview path construction ////////////
    
    CGPathAddArc(previewPath, nil, startPoint.x, startPoint.y, ORIGIN_RADIUS, 0, M_PI * 2, 0);    
    CGPathMoveToPoint(previewPath, nil, startPoint.x, startPoint.y);
    CGPathAddQuadCurveToPoint(previewPath, nil, controlPoint.x, controlPoint.y, endPoint.x, endPoint.y);
    [VArrow drawInPath:previewPath withVector:CGPointMake(delta.x, delta.y)];
    
    previewPathBounds = CGPathGetBoundingBox(previewPath);
}



- (void)drawInPath:(CGMutablePathRef)thePath withTransform:(CGAffineTransform *)affineTransform withReversed:(BOOL)reversed
{
    if (reversed) { // endPoint -> controlPoint -> startPoint
        CGPathAddQuadCurveToPoint(thePath, affineTransform, controlPoint.x, controlPoint.y, startPoint.x, startPoint.y);
    } else {        // startPoint -> controlPoint -> endPoint
        CGPathAddQuadCurveToPoint(thePath, affineTransform, controlPoint.x, controlPoint.y, endPoint.x, endPoint.y);
    }
}

// Tring to draw the all preview by myself with CGPath
- (void)drawPreviewInContext:(CGContextRef)ctx
{    
    CGContextAddPath(ctx, previewPath);
    CGContextStrokePath(ctx);
}

- (CGRect)getPreviewBounds
{
    return previewPathBounds;
}


////////////////////////////////////////////////////////////////////////////////////////////
/* 
 Old API Without CGPath design.
 All based on CGContext drawing and using one path (owned by the context) only.
 */

// This function will be used multiple time, don't use a static canvas string. (Bug Fixed)
- (NSString *)drawInContext:(CGContextRef)ctx withReversed:(BOOL)reversed
{
    if (reversed) { // endPoint -> controlPoint -> startPoint
        CGContextAddQuadCurveToPoint(ctx, controlPoint.x, controlPoint.y, startPoint.x, startPoint.y);
        //if (isCurve) {
            return [NSString stringWithFormat:@"quadraticCurveTo(%.3f, %.3f, %.3f, %.3f);\n", controlPoint.x, controlPoint.y, startPoint.x, startPoint.y];
    } else {        // startPoint -> controlPoint -> endPoint
        CGContextAddQuadCurveToPoint(ctx, controlPoint.x, controlPoint.y, endPoint.x, endPoint.y);
            return [NSString stringWithFormat:@"quadraticCurveTo(%.3f, %.3f, %.3f, %.3f);\n", controlPoint.x, controlPoint.y, endPoint.x, endPoint.y];
    }
}

@end
