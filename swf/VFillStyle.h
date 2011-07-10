//
//  VFillStyle.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/29.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>


#ifdef __cplusplus
#include "VObject.h"
#endif // __cplusplus

#import "VColor.h"
#import "VGradient.h"
#import "VMatrix.h"

@interface VFillStyle : NSObject <Previewable> {

// union? (TODO)
    VColor          *vColor;
    VGradient       *vGradient;
//
    
    
    uint            fillStyleType;
#ifdef __cplusplus
    VObject         *vFillStyle;
#endif // __cplusplus
    
    CGAffineTransform gradientMatrix;
    
    NSMutableArray  *vpaths;        // hold VPath objects.
    
    
    // Previewable
    CGMutablePathRef        previewPath;
    CGRect                  previewPathBounds;
    
    NSMutableString         *canvasStr;
}

@property (assign) NSMutableArray *vpaths;
@property (assign) CGAffineTransform gradientMatrix;


#ifdef __cplusplus
-(id) initWithFillStyleVObject:(VObject *)theFillStyle;
#endif // __cplusplus

- (void)drawPreviewInContext:(CGContextRef)ctx;

- (NSString *)applyOnContext:(CGContextRef)ctx;
- (void)parseFillStyle;

- (void)constructPreviewPath;

@end
