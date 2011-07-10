//
//  VFillStyle.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/29.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VFillStyle.h"


@implementation VFillStyle

@synthesize vpaths, gradientMatrix;


-(id) initWithFillStyleVObject:(VObject *)theFillStyle
{
    self = [super init];
    if (self) {
        canvasStr = [[NSMutableString alloc] init];
        
        // Preview
        previewPath = CGPathCreateMutable();
        [self constructPreviewPath];
        
        vFillStyle = theFillStyle;
        vpaths = [[NSMutableArray alloc] init];
        if (vFillStyle) {
            [self parseFillStyle];
        }
    }
    return self;
}

-(void)dealloc
{
    CGPathRelease(previewPath);
    [vColor release];
    [vGradient release];
    [vpaths removeAllObjects];
    [vpaths release];
    [canvasStr release];
    [super dealloc];
}


///// Previewable /////
- (void)constructPreviewPath
{
    CGPathAddRect(previewPath, nil, CGRectMake(0, 0, COLOR_BOX_WIDTH, COLOR_BOX_HEIGHT));
    previewPathBounds = CGPathGetBoundingBox(previewPath);
}

- (CGRect)getPreviewBounds
{
    return previewPathBounds;
}

- (void)drawPreviewInContext:(CGContextRef)ctx
{
    self.gradientMatrix = [VMatrix createGradientBox:CGRectMake(0, 0, COLOR_BOX_WIDTH, COLOR_BOX_HEIGHT)];    
    
    CGContextAddPath(ctx, previewPath);
    [self applyOnContext:ctx];
    
}

//////////////////


- (void)parseFillStyle
{
    VObject &fillstyle = (*vFillStyle);
    
    fillStyleType = fillstyle["FillStyleType"].asUInt();
    
    switch(fillStyleType) 
    {
        // Solid fill
        case 0x00:
            vColor = [[VColor alloc] initWithColorString:fillstyle["Color"].asString()];
            break;
            
        // Gradient Fills
        case 0x10:
        case 0x12:
        case 0x13:
            // GradientMatrix:MATRIX
            gradientMatrix = [VMatrix matrixOfMatrixVObject:&fillstyle["GradientMatrix"]];
            
            // Gradient:GRADIENT
            vGradient = [[VGradient alloc] initWithGradientVObject:&fillstyle["Gradient"] withGradientMatrix:gradientMatrix andType:fillStyleType];
            
            break;
        default:
            break;
    }
}

- (void)setGradientMatrix:(CGAffineTransform)_matrix
{
    [vGradient release];
    gradientMatrix = _matrix;
    vGradient = [[VGradient alloc] initWithGradientVObject:&(*vFillStyle)["Gradient"] withGradientMatrix:gradientMatrix andType:fillStyleType];
}

- (NSString *)applyOnContext:(CGContextRef)ctx
{
    switch (fillStyleType) {
        case 0x00: // solid color
            CGContextSetFillColorWithColor(ctx, vColor.color);
            CGContextFillPath(ctx);
            [canvasStr appendFormat:@"fillStyle = \"%@\";\n", vColor.canvasStr];
            break;
        case 0x10: // linear gradient            
            /* This is the difference between canvas, CGContext, adobe fill styles */
            CGContextSaveGState(ctx);
            CGContextClip(ctx);
            CGContextDrawLinearGradient(ctx, 
                                        vGradient.gradient,
                                        vGradient.startPoint,
                                        vGradient.endPoint,
                                        kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation
                                        );
            CGContextRestoreGState(ctx);
            
            [canvasStr appendString:vGradient.canvasStr];
            [canvasStr appendString:@"fillStyle = gradient;\n"];
            break;
        case 0x12:  // radial
        case 0x13:  // focal
            CGContextSaveGState(ctx);
            CGContextClip(ctx);
            CGContextDrawRadialGradient(ctx, 
                                        vGradient.gradient, 
                                        vGradient.startPoint, 
                                        0, 
                                        vGradient.startPoint, // should be vGradient.endPoint ?
                                        vGradient.radius, 
                                        kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
            CGContextRestoreGState(ctx);

            [canvasStr appendString:vGradient.canvasStr];
            [canvasStr appendString:@"fillStyle = gradient;\n"];
            break;
        case 0x40:  // bitmap fill (TODO)
            break;
        default:
            CGContextSetRGBFillColor(ctx, 0, 1, 0, 1);
            break;
    }
    
    return canvasStr;
}


@end
