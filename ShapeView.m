//
//  ShapeView.m
//  VisualSWF
//
//  Created by Rintarou on 2011/2/11.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "ShapeView.h"
#import "VColor.h"
#import "F2CStyle.h"

#import "F2CView.h"

@implementation ShapeView

@synthesize drawer, isFocused, needCache;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        isFocused = NO;
    }
    return self;
}

- (void)dealloc
{
    //NSLog(@"ShapeView released");
    if (needCache) {
        CGLayerRelease(cgCache);
    }
    [super dealloc];
}

- (NSInteger)tag
{
    return viewTag;
}

- (void)setTag:(NSInteger)_tag
{
    viewTag = _tag;
}

- (BOOL)canDrawConcurrently
{
    return YES;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)viewDidMoveToSuperview
{
    if (needCache && [self superview]) {
        NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(buildCache) object:nil];        
        [(F2CView *)[self superview] addCacheBuildOperation:op];
        [op release];
    }
    //[self setNeedsDisplay:YES];
}

/*
- (void)setNeedCache:(BOOL)flag {
    needCache = flag;
    if (needCache) {
        //[self performSelectorInBackground:@selector(buildCache) withObject:nil];    // start the build cache thread

    }
}
*/

- (void)cacheReady
{
    isCacheReady = YES;
    [self setNeedsDisplay:YES];
}


/* Cache Build Thread for complex shapes which need be cached */
- (void)buildCache
{
    //NSLog(@"created a new thread");
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGRect shapeBounds = [drawer shapeBounds];
    cgCache = CGLayerCreateWithContext(context, CGSizeMake(shapeBounds.size.width, shapeBounds.size.height), NULL);

    CGContextRef cgContext = CGLayerGetContext(cgCache);
    if (cgContext) {
        CGContextTranslateCTM(cgContext, -shapeBounds.origin.x, -shapeBounds.origin.y);
        [drawer drawInContext: cgContext];
    }
    
    [self performSelectorOnMainThread:@selector(cacheReady) withObject:nil waitUntilDone:NO];
    //NSLog(@"thread done");
    [pool release];
}

- (void)drawRect:(NSRect)dirtyRect {
    if (!drawer) {
        return;
    }

    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];

    if (!context)
        return;
    
    // Drawing code here.
    CGRect viewBounds = NSRectToCGRect([self bounds]);
    
    /* boxBounds is the area for drawing */
    CGRect boxBounds = CGRectMake(viewBounds.origin.x + SHAPE_PADDING_LEFT, 
                                  viewBounds.origin.y + SHAPE_PADDING_TOP,
                                  viewBounds.size.width - SHAPE_PADDING_LEFT - SHAPE_PADDING_RIGHT,
                                  viewBounds.size.height - SHAPE_PADDING_TOP - SHAPE_PADDING_BOTTOM);

    /* original shape bounds */
    CGRect shapeBounds = [drawer shapeBounds];
    
    /* scaled shape bounds to fit into boxBounds */
    CGFloat boxRatio = boxBounds.size.height / boxBounds.size.width;
    CGFloat shapeRatio = shapeBounds.size.height / shapeBounds.size.width;
    CGFloat scaleRatio;

    if (shapeRatio >= boxRatio) {
        scaleRatio = boxBounds.size.height / shapeBounds.size.height; // use height as scaleRatio
    } else {
        scaleRatio = boxBounds.size.width / shapeBounds.size.width; // use width as scaleRatio
    }
    
    CGFloat scaledShapeWidth  = shapeBounds.size.width * scaleRatio;
    CGFloat scaledShapeHeight = shapeBounds.size.height * scaleRatio;
    
    CGRect fitInBoxBounds = CGRectMake((viewBounds.size.width - scaledShapeWidth) / 2,
                                       (viewBounds.size.height - scaledShapeHeight) / 2,
                                       scaledShapeWidth,
                                       scaledShapeHeight);
    
    /* Shadow */
    CGColorRef shadowColor = [VColor CSS2Color:SHAPE_SHADOW_COLOR];    
    CGContextSetShadowWithColor (context,
                                 CGSizeMake(3.0, -3.0),  // CGSize offset,
                                 4.0,                    // CGFloat blur,
                                 shadowColor             // CGColorRef color
                                 );    
    CGColorRelease(shadowColor);
    
    
    
    /* Default background color */
    if (isFocused) {
        [VColor setContextFillColor:context withCSSColor:SHAPE_VIEW_FOCUSED_BACKGROUND_COLOR];
    } else {
        [VColor setContextFillColor:context withCSSColor:SHAPE_VIEW_BACKGROUND_COLOR];
    }
    CGContextFillRect(context, viewBounds);
    
    [VColor setContextStrokeColor:context withCSSColor:SHAPE_VIEW_BORDER_COLOR];
    CGContextStrokeRect(context, viewBounds);
            
    [VColor setContextFillColor:context withCSSColor:SHAPE_DEFAULT_FILLCOLOR];
    [VColor setContextStrokeColor:context withCSSColor:SHAPE_DEFAULT_STROKE_COLOR];

    CGAffineTransform t = CGContextGetCTM(context);    
    CGContextSetTextMatrix(context, t);
    CGContextSelectFont(context, "Arno Pro", 12, kCGEncodingMacRoman);
    CGContextSetCharacterSpacing(context, 0);
    CGContextSetTextDrawingMode(context, kCGTextFill);

    NSString *shapeId = [NSString stringWithFormat:@"%d", [drawer shapeId]];
    CGContextShowTextAtPoint(context, 2, 12, [shapeId UTF8String], [shapeId length]);
    
    
    /* Start of Shape Drawing */        
    if (needCache) { /* Cached drawing */
        /* draw the cache on context */
        if (isCacheReady) {
            CGContextDrawLayerInRect(context, fitInBoxBounds, cgCache);
        } else {
            NSString *shapeId = [NSString stringWithFormat:@"%d - Loading...", [drawer shapeId]];
            CGContextShowTextAtPoint(context, 2, 12, [shapeId UTF8String], [shapeId length]);
        }
    } else { /* Non-cached drawing */    
        cgCache = CGLayerCreateWithContext(context, CGSizeMake(shapeBounds.size.width, shapeBounds.size.height), NULL);
        CGContextRef cgContext = CGLayerGetContext(cgCache);
        if (cgContext) {
            CGContextTranslateCTM(cgContext, -shapeBounds.origin.x, -shapeBounds.origin.y);
            [drawer drawInContext: cgContext];
        }
        /* draw the cache on context */
        CGContextDrawLayerInRect(context, fitInBoxBounds, cgCache);
        CGLayerRelease(cgCache);
    }
}

@end
