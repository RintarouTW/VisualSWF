//
//  ShapeViewController.m
//  VisualSWF
//
//  Created by Rintarou on 2011/2/11.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "ShapeViewController.h"

#import "build.h"
#import "F2CStyle.h"
#import "Share.h"   // for debug
#import "VColor.h"

#import "CodeGen.h"

#define NON_CACHE_MAX_NUM_RECORDS       2000

@implementation ShapeViewController

- (id)initWithTag:(VObject *)_tag
{
    self = [super init];
    if (self) {
        [self loadView];
        tag = _tag;
        
        drawer = [[VDefineShape alloc] initWithVObject:tag];
        
        if (drawer.numShapeRecords > NON_CACHE_MAX_NUM_RECORDS) {
            shapeView.needCache = YES;            
        }
        
        /* set view's tag to ShapeId */
        [shapeView setTag:drawer.shapeId];
    }
    return self;
}

- (void)dealloc
{
    //NSLog(@"ShapeViewController released");
    [shapeView removeFromSuperview];
    [shapeView release];
    [drawer release];
    [super dealloc];
}

// override the loadView
- (void)loadView
{
    NSRect shapeViewFrame;
    shapeViewFrame.origin.x    = 0;
    shapeViewFrame.origin.y    = 0;
    shapeViewFrame.size.width  = SHAPE_VIEW_WIDTH;
    shapeViewFrame.size.height = SHAPE_VIEW_HEIGHT;
    shapeView = [[ShapeView alloc] initWithFrame:shapeViewFrame];
    shapeView.drawer = self;
    self.view = shapeView;
}

///// getter for properties
// Code Generation
- (NSMutableString *)canvasCodeWithCast
{
    return [CodeGen genCodeOfShapes:[NSArray arrayWithObject:drawer]];
}

- (NSMutableString *)canvasCode
{
    return [CodeGen genCodeOfShape:drawer];
}

- (NSMutableString *)characterName
{
    return [CodeGen genCharacterName:drawer];
}


- (CGRect)shapeBounds
{
    return [drawer getPreviewBounds];
}

- (uint)shapeId
{
    return drawer.shapeId;
}


///// implement drawer protocol
- (void)drawInContext:(CGContextRef)context
{
    /* Draw the shape */
    CGContextBeginTransparencyLayer(context, NULL);
    [drawer drawPreviewInContext:context];
    CGContextEndTransparencyLayer(context);    
}

@end
