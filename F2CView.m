//
//  F2CView.m
//  VisualSWF
//
//  Created by Rintarou on 2011/2/10.
//  Copyright 2011 http://rintarou.dyndns.org. All rights reserved.
//

#import "F2CView.h"
#import "F2CStyle.h"
#import "ShapeView.h"

#import "VColor.h"

@implementation F2CView

@synthesize delegate;


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        //[self setWantsLayer:YES];
        [[self window] setAcceptsMouseMovedEvents:YES];        
        [self updateTrackingAreas];
        cacheBuildQueue = [[NSOperationQueue alloc] init];
        [cacheBuildQueue setMaxConcurrentOperationCount:2];
    }
    return self;
}

- (void)dealloc
{
    [trackingArea release];
    [cacheBuildQueue cancelAllOperations];
    [cacheBuildQueue waitUntilAllOperationsAreFinished];    
    [cacheBuildQueue release];
    [super dealloc];
}

/* Cache Queue */
- (void)addCacheBuildOperation:(NSOperation *)op
{
    [cacheBuildQueue addOperation:op];
}

- (BOOL)isFlipped
{
    return YES;
}


- (void)reset
{
    [self setFrameSize:[[self superview] bounds].size];
    focusedView = nil;
    [cacheBuildQueue cancelAllOperations];
    [cacheBuildQueue waitUntilAllOperationsAreFinished];
}

- (void)updateTrackingAreas
{
    [trackingArea release];
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways )
                                                  owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];    
}


- (void)mouseMoved:(NSEvent *)theEvent
{
    NSPoint evtLocationInSuperView = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    NSView *hitView = [self hitTest:evtLocationInSuperView];

    /* focus changed */
    if (hitView && (hitView != focusedView)) 
    {                
        ((ShapeView *)focusedView).isFocused = NO;
        [focusedView setNeedsDisplay:YES];
        if (hitView != self) {
            focusedView = hitView;
            ((ShapeView *)focusedView).isFocused = YES;
            [focusedView setNeedsDisplay:YES];
        } else {
            focusedView = nil;
        }
        [delegate focusChange:focusedView]; /* Notify the delegate focus is changed */
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint evtLocationInSuperView = [[self superview] convertPoint:[theEvent locationInWindow] fromView:nil];
    NSView *hitView = [self hitTest:evtLocationInSuperView];
    if (hitView && hitView != self) {
        [delegate select:hitView];
    }
}


// override addSubView to modify the view's frame.
- (void)addSubview:(NSView *)aView
{
    uint numSubviews = [[self subviews] count];
    
    uint boxY  = numSubviews * (SHAPE_VIEW_HEIGHT + SHAPE_VIEW_BOTTOM_PADDING);
    uint boxY2 = boxY + (SHAPE_VIEW_HEIGHT + SHAPE_VIEW_BOTTOM_PADDING);
    
    // modify aView's frame.
    NSRect viewFrame;
    viewFrame.origin.x      = SHAPE_VIEW_ORIGIN_X;
    viewFrame.origin.y      = boxY;
    viewFrame.size.width    = SHAPE_VIEW_WIDTH;
    viewFrame.size.height   = SHAPE_VIEW_HEIGHT;
    [aView setFrame:viewFrame];
    [super addSubview:aView];
    
    NSRect myFrame = [self frame];

    if (boxY2 > myFrame.size.height) {
        myFrame.size.height = boxY2;
    }
    
    [self setFrame:myFrame];
}

- (void)drawRect:(NSRect)dirtyRect {
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];

    // Drawing code here.
    //CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
    [VColor setContextFillColor:context withCSSColor:F2C_VIEW_BACKGROUND_COLOR];
    CGContextFillRect(context, NSRectToCGRect([self bounds]));
}

@end
