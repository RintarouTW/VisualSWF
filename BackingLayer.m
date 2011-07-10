//
//  BackingLayer.m
//  
//
//  Created by Rintarou on 2011/1/19.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "BackingLayer.h"

#import "VColor.h"
#import "style.h"


@implementation BackingLayer

@synthesize linkLayer, previewLayer;

- (id)init
{
    self = [super init];
    if (self) {
        self.geometryFlipped = YES;
    }
    return self;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// delegate of the backing layer
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)drawInContext:(CGContextRef)ctx
{   
    /* Background Color */
    [VColor setContextFillColor:ctx withCSSColor:BACKGROUND_COLOR];
    
    CGContextFillRect(ctx, [self bounds]);
}

- (void)setBounds:(CGRect)theRect
{
    [linkLayer setFrame:theRect];
    [super setBounds:theRect];
}

- (void)setFrame:(CGRect)theRect
{
    [super setFrame:theRect];
    theRect = [self bounds];
    [linkLayer setFrame:theRect];
}

@end
