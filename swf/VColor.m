//
//  VColor.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/26.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VColor.h"


@implementation VColor

@synthesize color, canvasStr;

+ (CGColorRef)CSS2Color:(const char *)cssColor
{
    /* CSS Color String Format
     1. "0xRRGGBB"
     2. "0xAARRGGBB"
     */    
    uint i = [Shared string2uint:cssColor];
    
    CGFloat a = 1.0, r, g, b;
    if (strlen(cssColor) > 8) {
        if ((i >> 24) < 255) {
            a = ((i >> 24) & 0xff) / 256.0;
        }
    }
    b = (i & 0x000000ff) / 256.0;
    g = ((i & 0x0000ff00) >> 8) / 256.0;
    r = ((i & 0x00ff0000) >> 16) / 256.0;
    
    CGColorRef colorRef = CGColorCreateGenericRGB(r, g, b, a);
    return colorRef;
}

+ (void)setContextFillColor:(CGContextRef)context withCSSColor:(const char *)cssColorStr
{
    CGColorRef color = [VColor CSS2Color:cssColorStr];
    CGContextSetFillColorWithColor(context, color);
    CGColorRelease(color);
}

+ (void)setContextStrokeColor:(CGContextRef)context withCSSColor:(const char *)cssColorStr
{
    CGColorRef color = [VColor CSS2Color:cssColorStr];
    CGContextSetStrokeColorWithColor(context, color);
    CGColorRelease(color);
}


+ (CGColorRef)string2Color:(const char *)_colorStr
{
    /* colorStr format: 
     1. SWF RGB  -> "0xBBGGRR"
     2. SWF RGBA -> "0xAABBGGRR"
     */
    uint i = [Shared string2uint:_colorStr];
    
    CGFloat a = 1.0, r, g, b;
    
    if (strlen(_colorStr) > 8) {
        a = ((i >> 24) & 0xff) / 256.0;
    }
    
    r = (i & 0x000000ff) / 256.0;
    g = ((i & 0x0000ff00) >> 8) / 256.0;
    b = ((i & 0x00ff0000) >> 16) / 256.0;
    
    CGColorRef colorRef = CGColorCreateGenericRGB(r, g, b, a);

    /*
     CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear);
     CGFloat components[] = {r, g, b, a};
     CGColorRef colorRef = CGColorCreate(colorSpace, components);
     */
    
    return colorRef;
}

// return an autoreleased NSMutableString
+ (NSString *)string2CanvasColorFormat:(const char *)_colorStr
{
    NSMutableString *canavsColor = [[[NSMutableString alloc] init] autorelease];
    
    uint i = [Shared string2uint:_colorStr];
    
    
    unsigned char aByte, rBtye, gByte, bByte;
    
    aByte = ((i >> 24) & 0xff);        
    rBtye = (i & 0x000000ff);
    gByte = ((i & 0x0000ff00) >> 8);
    bByte = ((i & 0x00ff0000) >> 16);
    
    if (strlen(_colorStr) > 8) {
        [canavsColor appendFormat:@"rgba(%d, %d, %d, %d)", rBtye, gByte, bByte, aByte];
    } else {
        [canavsColor appendFormat:@"rgb(%d, %d, %d)", rBtye, gByte, bByte];
    }
    
    return canavsColor;
}

- (id)initWithColorString:(const char *)_colorStr
{
    self = [super init];
    if (self) {
        canvasStr = [[NSMutableString alloc] init];
        if (!canvasStr)
            abort();
        previewPath = CGPathCreateMutable();
        [self constructBoxPath];
        [self parseWithColorString:_colorStr];
        
    }
    return self;
}

- (void)parseWithColorString:(const char *)_colorStr
{
    
    uint i = [Shared string2uint:_colorStr];
    
    CGFloat a = 1.0, r, g, b;
    
    unsigned char aByte, rBtye, gByte, bByte;
    
    aByte = ((i >> 24) & 0xff);        
    rBtye = (i & 0x000000ff);
    gByte = ((i & 0x0000ff00) >> 8);
    bByte = ((i & 0x00ff0000) >> 16);
    
    
    if (strlen(_colorStr) > 8) {
        if (aByte < 255) {
            a = aByte / 256.0;
        }
    }
    
    r = rBtye / 256.0;
    g = gByte / 256.0;
    b = bByte / 256.0;
    
    color = CGColorCreateGenericRGB(r, g, b, a);
        
    if (strlen(_colorStr) > 8) {
        [canvasStr appendFormat:@"rgba(%d, %d, %d, %d)", rBtye, gByte, bByte, aByte];
    } else {
        [canvasStr appendFormat:@"rgb(%d, %d, %d)", rBtye, gByte, bByte];
    }
    
    //NSLog(@"%s", [canvasStr UTF8String]);
}


- (void)dealloc
{
    CGColorRelease(color);
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
    CGContextSetFillColorWithColor(ctx, color);
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 1.0);
    CGContextAddPath(ctx, previewPath);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}


@end
