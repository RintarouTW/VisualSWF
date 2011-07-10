//
//  VGradient.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/30.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
#import "VObject.h"
#endif // __cplusplus

#import "VColor.h"

#import "Previewable.h" // VGradient is Previewable.

@interface VGradient : NSObject <Previewable> {
    
#ifdef __cplusplus
    VObject             *vGradient;
#endif // __cplusplus
    //CGColorSpaceRef     colorSpace;     // DeviceRGB so far.
    CGGradientRef       gradient;
    uint                gradientType;
    CGAffineTransform   gradientMatrix;
    
    CGPoint             startPoint;
    CGPoint             endPoint;
    CGFloat             radius;
    
    CGFloat             focalPointRation;   // TODO
    
    /* Previewable */
    CGRect              previewPathBounds;
    CGMutablePathRef    previewPath;    // New for trying CGPath design since CGPath has CGPathGetBoundingBox: to tell the size.
    
    NSMutableString     *canvasStr;
}

@property (readonly) CGGradientRef  gradient;
@property (readonly) CGPoint        startPoint;
@property (readonly) CGPoint        endPoint;
@property (readonly) CGFloat        radius;
@property (readonly) NSMutableString *canvasStr;

#ifdef __cplusplus
- (id)initWithGradientVObject:(VObject *)gradientVObject withGradientMatrix:(CGAffineTransform)_gradientMatrix andType:(uint)_gradType;
#endif // __cplusplus

- (CGRect)getPreviewBounds;
- (void)drawPreviewInContext:(CGContextRef)ctx; // Implemented Previewable protocol

/* Internal used methods */
- (void)constructBoxPath;


- (void)parseGradient;

@end
