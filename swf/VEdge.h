//
//  VEdge.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/24.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>


#import "VArrow.h"

// We implemented Previewable protocol.
#import "Previewable.h"

@interface VEdge : NSObject <Previewable> {
    /* 
       - startPoint, endPoint, controlPoint) are in absolute position instead of relative offset. (in pixel so far)
         Both Canvas and CGPath are designed in absolute position, although SWF edge records are designed to store offset data.
       - deltaX, deltaY are vectors for drawing the arrow.
         1. Line : delta = end - start
         2. Curve : delta = end - control
     */
    
    /* in pixel so far */
    CGPoint             startPoint;
    CGPoint             endPoint;
    CGPoint             controlPoint;
    CGPoint             delta;
    BOOL                isCurve;               // isCurve just a flag to tell the original data is a stragt line, although it's a curve internally.
    
    // Previewable
    CGRect              previewPathBounds;
    CGMutablePathRef    previewPath;

//    NSMutableString     *canvasStr;
}

@property (readonly) BOOL       isCurve;
@property (readonly) CGPoint    startPoint;
@property (readonly) CGPoint    endPoint;
@property (readonly) CGPoint    controlPoint;
@property (readonly) CGPoint    delta;
//@property (readonly) NSString   *canvasStr;

// theStartPoint, theControPoint, theEndPoint are in twips
- (void) asLineWithStart:(CGPoint)twipStartPoint andEnd:(CGPoint)twipEndPoint; 
- (void) asCurveWithStart:(CGPoint)twipStartPoint andControl:(CGPoint)twipControlPoint andEnd:(CGPoint)twipEndPoint;

- (void) drawPreviewInContext:(CGContextRef)ctx; // designed for preview layer
- (CGRect) getPreviewBounds;

- (NSString *) drawInContext:(CGContextRef)ctx withReversed:(BOOL)reversed;
- (void )drawInPath:(CGMutablePathRef)thePath withTransform:(CGAffineTransform *)affineTransform withReversed:(BOOL)reversed;          // draw in a CGPath.

@end
