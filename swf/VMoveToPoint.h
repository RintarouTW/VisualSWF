//
//  VMoveToPoint.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/27.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>


@interface VMoveToPoint : NSObject {
    CGPoint moveTo;     // in pixel
    CGPoint delta;
    CGPoint from;
}

@property (readonly) CGPoint moveTo;
@property (readonly) CGPoint delta;
@property (readonly) CGPoint from;

- (id)initWithMoveToPoint:(CGPoint)theMoveToPoint;  // in twips

- (void)drawInPath:(CGMutablePathRef)thePath withTransform:(CGAffineTransform *)affineTransform;

@end
