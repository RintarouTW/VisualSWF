//
//  VDfineShape.h
//  VisualSWF
//
//  Created by Rintarou on 2011/2/1.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Previewable.h" // This is Previewable.

#ifdef __cplusplus
#import "VObject.h"
#endif // __cplusplus


#import "VShapeWithStyle.h"

@interface VDefineShape : NSObject <Previewable> {

    
#ifdef __cplusplus
    VObject     *vDefineShape;
#endif // __cplusplus
    
    VShapeWithStyle     *shapeWithStyle;
    
    uint                shapeId;
    
    // Preivew
    CGRect              previewPathBounds;    // using ShapeBounds
    //CGMutablePathRef    previewPath;        // no needed, since ShapeBounds was declared.
}

@property (readonly) NSMutableString *canvasStr;
@property (readonly) uint            shapeId;
@property (readonly) uint            numShapeRecords;

#ifdef __cplusplus
- (id)initWithVObject:(VObject *)defineShapeVObject;
#endif // __cplusplus

- (void)drawPreviewInContext:(CGContextRef)ctx;
- (CGRect)getPreviewBounds;


@end
