//
//  ShapeDrawer.h
//  VisualSWF
//
//  Created by Rintarou on 2011/2/11.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol ShapeDrawer

- (void)drawInContext:(CGContextRef)context;
- (CGRect)shapeBounds;
- (uint)shapeId;

@end
