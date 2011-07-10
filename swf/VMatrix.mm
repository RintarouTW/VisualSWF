//
//  VMatrix.m
//  VisualSWF
//
//  Created by Rintarou on 2011/1/30.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "VMatrix.h"


@implementation VMatrix

@synthesize matrix;

+ (CGAffineTransform)createGradientBox:(CGRect)theBox
{
    
    CGAffineTransform mat = 
    { 
        theBox.size.width * TWIPS_PER_PIXEL / (SWF_GRADIENT_SQAURE * 2),
        0,
        0,
        theBox.size.height * TWIPS_PER_PIXEL / (SWF_GRADIENT_SQAURE * 2),
        theBox.size.width  / 2 + theBox.origin.x,
        theBox.size.height / 2 + theBox.origin.y
    };
    
    return mat;
}

/* Convinient Method without instance allocation */
+ (CGAffineTransform)matrixOfMatrixVObject:(VObject *)_matrixVObject
{
    CGAffineTransform transform;
    VObject &mat = (*_matrixVObject);
    if (mat["HasScale"].asUInt()) {
        transform.a = mat["ScaleX"].asDouble();
        transform.d = mat["ScaleY"].asDouble();
    }
    
    if (mat["HasRotate"].asUInt()) {
        transform.b = mat["RotateSkew0"].asDouble();
        transform.c = mat["RotateSkew1"].asDouble();
    }
    
    transform.tx = mat["TranslateX"].asInt() / TWIPS_PER_PIXEL;
    transform.ty = mat["TranslateY"].asInt() / TWIPS_PER_PIXEL;
    return transform;
}


- (id) initWithMatrixVObject:(VObject *)_matrixVObject
{
    self = [super init];
    if (self) {
        if (_matrixVObject) {
            vMatrix = _matrixVObject;
            [self parseMatrix];
        }
    }
    return self;
}

- (void) parseMatrix
{
    VObject &mat = (*vMatrix);
    if (mat["HasScale"].asUInt()) {
        matrix.a = mat["ScaleX"].asDouble();
        matrix.d = mat["ScaleY"].asDouble();
    }
    
    if (mat["HasRotate"].asUInt()) {
        matrix.b = mat["RotateSkew0"].asDouble();
        matrix.c = mat["RotateSkew1"].asDouble();
    }
    
    matrix.tx = mat["TranslateX"].asInt() / TWIPS_PER_PIXEL;
    matrix.ty = mat["TranslateY"].asInt() / TWIPS_PER_PIXEL;
}


- (void) dealloc
{
    [super dealloc];
}

@end
