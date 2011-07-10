//
//  VPath.h
//  VisualSWF
//
//  Created by Rintarou on 2011/1/24.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "Share.h"

#import "VEdge.h"

#import <Cocoa/Cocoa.h>

// TODO: Consider how VPath can work with CGPath... Important. Even including path morphing?
@interface VPath : NSObject {
    NSMutableArray *edgeList;
    BOOL reversed;
    NSMutableString *canvasStr;
}

@property (readonly) BOOL isRightFill;

- (id)initWithEdges:(NSMutableArray *)edges withRightFill:(BOOL)_isRightFill;
- (CGPoint)startPoint;
- (CGPoint)endPoint;
- (NSString *)drawInContext:(CGContextRef)ctx;
- (NSString *)draw2InContext:(CGContextRef)ctx;

@end
