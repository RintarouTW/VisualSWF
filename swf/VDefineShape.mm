//
//  VDfineShape.m
//  VisualSWF
//
//  Created by Rintarou on 2011/2/1.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VDefineShape.h"

#ifdef F2C
#import "CodeGen.h"
#endif // F2C

@implementation VDefineShape

@synthesize shapeId;

- (id)initWithVObject:(VObject *)defineShapeVObject
{
    self = [super init];
    if (self) {

        if (defineShapeVObject) {
            vDefineShape = defineShapeVObject;
            shapeId      = (*vDefineShape)["ShapeId"].asUInt();
            
            // Using ShapeBounds as our PreviewBounds
            previewPathBounds.origin.x    = (*vDefineShape)["ShapeBounds"]["Xmin"].asInt() / TWIPS_PER_PIXEL;
            previewPathBounds.origin.y    = (*vDefineShape)["ShapeBounds"]["Ymin"].asInt() / TWIPS_PER_PIXEL;
            previewPathBounds.size.width  = (*vDefineShape)["ShapeBounds"]["Xmax"].asInt() / TWIPS_PER_PIXEL - previewPathBounds.origin.x;
            previewPathBounds.size.height = (*vDefineShape)["ShapeBounds"]["Ymax"].asInt() / TWIPS_PER_PIXEL - previewPathBounds.origin.y;
            
            shapeWithStyle = [[VShapeWithStyle alloc] initWithShapeWithStyle:&((*vDefineShape)["Shapes"])];
        }
    }
    return self;
}

- (void) dealloc
{
    [shapeWithStyle release];
    [super dealloc];
}

- (void)drawPreviewInContext:(CGContextRef)ctx
{    
    [shapeWithStyle drawPreviewInContext:ctx];
        
    /* Template to gen canvas code */
    /* Old Template */
    
#if 0
    [canvasStr appendFormat:@"    /* Shape ID : %d */\n", shapeId];
    [canvasStr appendFormat:@"    /* Width    : %d pixels */\n", (uint)previewPathBounds.size.width];
    [canvasStr appendFormat:@"    /* Height   : %d pixels */\n\n", (uint)previewPathBounds.size.height];

    [canvasStr appendString:@"    function drawShape(canvasID) {\n"];
    [canvasStr appendString:@"        var ctx = document.getElementById(canvasID).getContext('2d');\n"];    
    [canvasStr appendString:@"        /* Shape drawing start here */\n"];
    [canvasStr appendString:@"        with(ctx) {\n"];
    [canvasStr appendFormat:@"        translate(%.3f, %.3f); /* Translate to the origin of the shape */\n", -previewPathBounds.origin.x, -previewPathBounds.origin.y];
    [canvasStr appendString:shapeWithStyle.canvasStr];
    [canvasStr appendString:@"        }\n"];
    [canvasStr appendString:@"    }\n"];
#endif
    
}

- (CGRect)getPreviewBounds
{
    return previewPathBounds;
}

//getter
- (NSString *)canvasStr
{
    return shapeWithStyle.canvasStr;    // CodeGen should deal with the template of code generation.
}

- (uint)numShapeRecords
{
    return shapeWithStyle.numShapeRecords;
}

@end
