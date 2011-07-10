//
//  VGradient.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/30.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VGradient.h"


@implementation VGradient

@synthesize gradient, startPoint, endPoint, radius, canvasStr;

- (id)initWithGradientVObject:(VObject *)gradientVObject withGradientMatrix:(CGAffineTransform)_gradientMatrix andType:(uint)_gradType;
{
    self = [self init];
    if (self) {
        canvasStr = [[NSMutableString alloc] init];
        
        if (!gradientVObject) {
            NSLog(@"ALERT: NULL gradientVObject");
        }
        
        previewPath     = CGPathCreateMutable();
        vGradient       = gradientVObject;
        gradientType    = _gradType;        // 0x10 : linear
                                            // 0x12 : radial
                                            // 0x13 : focal
        gradientMatrix  = _gradientMatrix;
        
        [self parseGradient];
        [self constructBoxPath];
    }
    return self;
}

- (void)dealloc
{
    CGGradientRelease(gradient);
    CGPathRelease(previewPath);
    [canvasStr release];
    [super dealloc];
}


- (void)constructBoxPath
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
    CGContextAddPath(ctx, previewPath);
    CGContextSaveGState(ctx);
    CGContextClip(ctx);
    CGContextDrawLinearGradient(ctx, 
                                gradient,
                                startPoint,
                                endPoint,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation
                                );
    CGContextRestoreGState(ctx);
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 1.0);
    CGContextAddPath(ctx, previewPath);
    CGContextStrokePath(ctx);
}


- (void)parseGradient
{
    VObject &grad = (*vGradient);
    
    
    // startPoint, endPoint (Range of the gradient)
    switch (gradientType) {
        case 0x10:  // linear
            startPoint = CGPointMake(-16384 / TWIPS_PER_PIXEL, 0);  // (-1, 0)
            endPoint   = CGPointMake(16384  / TWIPS_PER_PIXEL, 0);  // ( 1, 0)
            startPoint = CGPointApplyAffineTransform(startPoint, gradientMatrix);
            endPoint   = CGPointApplyAffineTransform(endPoint, gradientMatrix);
            
            [canvasStr appendFormat:@"gradient = createLinearGradient(%.3f, %.3f, %.3f, %.3f);\n", startPoint.x, startPoint.y, endPoint.x, endPoint.y];
            break;
        case 0x12:  // radial
        case 0x13:  // focal (TODO)
            startPoint = CGPointMake(0, 0);     // the center point // (0, 0)
            endPoint   = CGPointMake(16384  / TWIPS_PER_PIXEL, 0);  // (1, 0)
            startPoint = CGPointApplyAffineTransform(startPoint, gradientMatrix);
            endPoint   = CGPointApplyAffineTransform(endPoint, gradientMatrix);            
            radius     = (endPoint.x - startPoint.x);
            
            [canvasStr appendFormat:@"gradient = createRadialGradient(%.3f, %.3f, 0, %.3f, %.3f, %.3f);\n", startPoint.x, startPoint.y, startPoint.x, startPoint.y, radius];
            break;
        default:
            break;
    }

    // SpreadMode (TODO)
    // Canvas not supported, CGPath How TO?

    CGColorSpaceRef colorSpace;
    // InterpolationMode (TODO)
    switch (grad["InterpoationMode"].asUInt()) {
        case 0: // RGB
            colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);       // - RGB       -> kCGColorSpaceGenericRGB?
            break;
        case 1: // LINEAR_RGB
            colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear); // - LinearRGB -> kCGColorSpaceGenericRGBLinear ?
            break;
        default:
            break;
    }

    //
    // GradientRecords
    //
    VObject &gradRecords = grad["GradientRecords"];
    int numRecords = gradRecords.length();
    if (numRecords > 15) {
        NSLog(@"ASSERT: GradientRecords num > 15 = %d", numRecords);
    }
    CGFloat locations[16];
    CGColorRef colorsRef[16];
    
    for (int i = 0; i < numRecords; i++) {
        locations[i] = (CGFloat)(gradRecords[i]["Ratio"].asUInt()) / 255;  // Ratio -> location?
        //NSLog(@"locations[%d] = %.3f", i, locations[i]);
        
        const char *colorString = gradRecords[i]["Color"].asString();
        colorsRef[i] = [VColor string2Color:colorString];    // when to release? (TODO)
        
        [canvasStr appendFormat:@"gradient.addColorStop(%.3f, \"%@\");\n", locations[i], [VColor string2CanvasColorFormat:colorString]];
    }
    
    CFArrayRef colors = CFArrayCreate(NULL, (const void**)colorsRef, numRecords, &kCFTypeArrayCallBacks);
    gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
    
    CFRelease(colorSpace);
    for (int i = 0; i < numRecords; i++) {
        CGColorRelease(colorsRef[i]);
    }
    CFRelease(colors);
}



@end
