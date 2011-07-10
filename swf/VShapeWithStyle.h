//
//  VShapeWithStyle.h
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

#import "VEdge.h"
#import "VMoveToPoint.h"

#import "VPath.h"
#import "VFillStyle.h"
#import "VLineStyle.h"

@interface VShapeWithStyle : NSObject {

#ifdef __cplusplus
    VObject             *vFillStyles;
    VObject             *vLineStyles;
    VObject             *vShapeRecords;         // we just want to read.
    VObject             *vShapeWithFillStyle;   // Exact the VObject we present for.
#endif // __cplusplus
    
    NSMutableArray      *vpaths;        // to hold VEdge, VMoveToPoint, for future extension. TODO. (This is useful to make drawing sequence serialized.)

    NSMutableArray      *fillStyles;
    NSMutableArray      *lineStyles;
    
    // Indexes to fillStyles and lineStyles.
    uint                currFileStyle0;
    uint                currFileStyle1;
    uint                currLineStyle;


    
    NSMutableArray      *f0Edges;
    NSMutableArray      *f1Edges;
    NSMutableArray      *lineEdges;
    
    VFillStyle          *emptyFillStyle;
    VLineStyle          *emptyLineStyle;

//    CGMutablePathRef    previewPath;
//    CGRect              previewPathBounds;
    uint                numShapeRecords;
    
    CGPoint             pen;
    
    NSMutableString     *canvasStr;
    
    CGContextRef        myContext;
}

@property (readonly) NSMutableString *canvasStr;
@property (readonly) uint           numShapeRecords;

#ifdef __cplusplus
- (id) initWithShapeWithStyle:(VObject *)theShapeWithStyleVObject;
#endif // __cplusplus

- (void)drawPreviewInContext:(CGContextRef)ctx;

//- (void)readRecordsForBounds;
- (void)readFillStyles;
- (void)readLineStyles;

@end
