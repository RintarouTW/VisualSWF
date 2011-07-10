//
//  VLineStyle.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/29.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VLineStyle.h"


@implementation VLineStyle

@synthesize vpaths, canvasStr;

-(id) initWithLineStyleVObject:(VObject *)theLineStyle
{
    self = [super init];
    if (self) {

        canvasStr = [[NSMutableString alloc] init];
        if (theLineStyle) {
            vLineStyle = theLineStyle;
            vpaths = [[NSMutableArray alloc] init];        
            [self parse];
        } else {
            //NSLog(@"ALERT: theLineStyle is null, should be the only one emptyLineStyle.");
        }
    }
    return self;
}

-(void)dealloc
{
    [canvasStr release];
    [vpaths removeAllObjects];
    [vpaths release];
    [super dealloc];
}

- (void)parse
{
    VObject &linestyle = (*vLineStyle);
    
    if (strcmp(linestyle.getTypeInfo(), "LINESTYLE") == 0) {
        lineStyleType = 1; // LINESTYLE
        thicness = linestyle["Width"].asUInt() / TWIPS_PER_PIXEL;
        vColor = [[VColor alloc] initWithColorString:linestyle["Color"].asString()];
        
        [canvasStr appendFormat:@"lineWidth = %.3f;\n", thicness];
        [canvasStr appendFormat:@"strokeStyle = \"%@\";\n", vColor.canvasStr];
    }

    if (strcmp(linestyle.getTypeInfo(), "LINESTYLE2") == 0) {
        lineStyleType = 2; // LINESTYLE2
        thicness = linestyle["Width"].asUInt() / TWIPS_PER_PIXEL;
        
        
        // StartCapStyle (TODO)
        // Quartz not support?
        const char *capStr[] = { "round", "butt", "square" };
        
        // EndCapStyle
        switch (linestyle["EndCapStyle"].asUInt()) {
            case 0:     // Round
                cap = kCGLineCapRound;
                break;
            case 1:     // No cap
                cap = kCGLineCapButt;
                break;
            case 2:     // Square
                cap = kCGLineCapSquare;
                break;
            default:
                break;
        }
        
        // JoinStyle
        const char *joinStr[] = { "round", "bevel", "miter" };
        
        switch (linestyle["JoinStyle"].asUInt()) {
            case 0: // ROUND
                join = kCGLineJoinRound;
                break;
            case 1: // BEVEL
                join = kCGLineJoinBevel;
                break;
            case 2: // MITER
                join = kCGLineJoinMiter;
                miterLimit = linestyle["MiterLimitFactor"].asDouble();  // FIXED8.8
                break;
            default:
                break;
        }
        
        // Fill with Color or FillType(FILLSTYLE)        
        switch (linestyle["HasFillFlag"].asUInt()) {
            case 0: // use Color field
                hasFillFlag = NO;
                
                vColor = [[VColor alloc] initWithColorString:linestyle["Color"].asString()];
                [canvasStr appendFormat:@"strokeStyle = \"%@\";\n", vColor.canvasStr];                
                [canvasStr appendFormat:@"lineWidth = %.3f;\n", thicness];
                [canvasStr appendFormat:@"lineCap   = \"%s\";\n", capStr[cap]];
                [canvasStr appendFormat:@"lineJoin  = \"%s\";\n", joinStr[join]];
                if (join == 2) {
                    [canvasStr appendFormat:@"miterLimit = %.3f;\n", miterLimit];
                }
                
                break;
            case 1: // use FillType field (TODO)
                // Not implemented yet.
                hasFillFlag = YES;
                break;
            default:
                break;
        }
        
    }
    
}

- (NSString *)applyOnContext:(CGContextRef)ctx
{
    switch (lineStyleType) {
        case 1: // LINESTYLE
            CGContextSetLineWidth(ctx, thicness);
            CGContextSetStrokeColorWithColor(ctx, vColor.color);
            break;
        case 2: // LINESTYLE2
            CGContextSetLineWidth(ctx, thicness);
            CGContextSetLineCap(ctx, cap);
            CGContextSetLineJoin(ctx, join);
            if (join == kCGLineJoinMiter) {
                CGContextSetMiterLimit(ctx, miterLimit);
            }
            if (!hasFillFlag) {
                CGContextSetStrokeColorWithColor(ctx, vColor.color);
            }

            break;
        default:
            break;
    }
    CGContextStrokePath(ctx);
    
    return canvasStr;
}

@end
