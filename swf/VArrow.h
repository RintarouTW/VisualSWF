//
//  VArrow.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/27.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>


@interface VArrow : NSObject {
    BOOL isExtendedMode;
    CGFloat length;
    CGFloat width;
    CGPoint directedVector;
}

@property (assign) CGFloat length;
@property (assign) CGFloat width;

+ (void)drawInPath:(CGMutablePathRef)thePath withVector:(CGPoint)theVector;
+ (void)drawInContext:(CGContextRef)ctx withVector:(CGPoint)theVector;

- (id)initWithVector:(CGPoint)theVector andExtendedMode:(BOOL)extendedMode;
- (void)drawInPath:(CGMutablePathRef)thePath withTransform:(CGAffineTransform *)affineTransform;

@end
