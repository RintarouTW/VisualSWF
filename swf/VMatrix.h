//
//  VMatrix.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/30.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
#import "VObject.h"
#endif // __cplusplus


@interface VMatrix : NSObject {
#ifdef __cplusplus
    VObject             *vMatrix;
#endif // __cplusplus
    
    CGAffineTransform   matrix;
}

@property (readonly) CGAffineTransform matrix;

+ (CGAffineTransform)createGradientBox:(CGRect)theBox;

#ifdef __cplusplus
+ (CGAffineTransform)matrixOfMatrixVObject:(VObject *)_matrixVObject; /* Convinient Method without instance allocation */
- (id) initWithMatrixVObject:(VObject *)_matrixVObject;
#endif // __cplusplus

- (void) parseMatrix;


@end
