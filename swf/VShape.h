//
//  VShape.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/24.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
#import "VObject.h"
#endif // __cplusplus

#import "VEdge.h"
#import "VMoveToPoint.h"

// Implemented Previewable protocol
#import "Previewable.h"

@interface VShape : NSObject <Previewable> {
#ifdef __cplusplus
    VObject             *shapeRecords;  // we just want to read.
#endif // __cplusplus
    
    NSMutableArray      *vpaths;        // to hold VEdge, VMoveToPoint, for future extension. TODO. (This is useful to make drawing sequence serialized.)
                                        // Consider the path model of CGPath, seems interesting.
    CGMutablePathRef    previewPath;
    CGRect              previewPathBounds;
    CGPoint             pen;
    
    NSTimer             *timer;
    uint                stepCounter;
    CALayer             *contextLayer;
    //BOOL                isStepDrawing;  // when stepCounter < [vpaths count], it's step drawing.
}

@property (assign)   CALayer *contextLayer;

#ifdef __cplusplus
- (id) initWithShape:(VObject *)theShapeVObject;
#endif // __cplusplus

- (void)drawPreviewInContext:(CGContextRef)ctx;
- (CGRect)getPreviewBounds;

- (void)startStepDrawing;
- (void)parseShapeRecords;
@end
