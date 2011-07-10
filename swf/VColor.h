//
//  VColor.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/26.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>

#import "Previewable.h"

@interface VColor : NSObject <Previewable> {
    CGColorRef          color;
        
    CGRect              previewPathBounds;
    CGMutablePathRef    previewPath;    // New for trying CGPath design since CGPath has CGPathGetBoundingBox: to tell the size.
    
    NSMutableString     *canvasStr;
}

@property (readonly) CGColorRef color;
@property (readonly) NSMutableString *canvasStr;

/* cssColor : "0xRRGGBB" / "0xAARRGGBB" */
+ (CGColorRef)CSS2Color:(const char *)cssColor;
+ (void)setContextFillColor:(CGContextRef)context withCSSColor:(const char *)cssColor;
+ (void)setContextStrokeColor:(CGContextRef)context withCSSColor:(const char *)cssColor;

/* _colorStr : "0xBBGGRR" / "0xAABBGGRR" */
+ (CGColorRef)string2Color:(const char *)_colorStr;
+ (NSString *)string2CanvasColorFormat:(const char *)_colorStr;

- (id)initWithColorString:(const char *)_colorStr;
- (void)parseWithColorString:(const char *)_colorStr;

- (CGRect)getPreviewBounds;
- (void)drawPreviewInContext:(CGContextRef)ctx; // designed for preview layer

/* Internal used methods */
- (void)constructBoxPath;


@end
