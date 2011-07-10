//
//  RootLayerDelegate.h
//  
//
//  Created by Rintarou on 2010/12/26.
//  Copyright 2010 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import <Cocoa/Cocoa.h>

#import "QuartzCore/QuartzCore.h"

#import "TableLayer.h"

@interface RootLayer : CALayer {
    NSMutableArray *columns;
    CGFloat height;
    CGFloat width;
    CGPoint clickPoint;
}

// RootLayer's real width is 0 for performance. (no need to compisoting)
// The following width and height are the virtual size of all tables.
@property (readonly) CGFloat height;
@property (readonly) CGFloat width;
@property (assign) CGPoint clickPoint;

- (void)addTable:(TableLayer *)table atColumn:(uint)col;

@end
